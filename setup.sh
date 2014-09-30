#!/bin/bash

START=$(date)

echo "Starting an Oracle container"
# run an Oracle container (without removing any existing, since that may just hurt too much)
docker run --privileged --name orcl -d wscherphof/oracle-12c 2> /dev/null
# in case it already existed and was stopped
docker start orcl
echo -n "Wait while ensuring the database has started..."
ERROR=true
while [ $ERROR ]; do
	ERROR=$(docker run --rm --link orcl:db -v $(pwd)/setup:/setup guywithnose/sqlplus /setup/connect | grep ERROR)
	if [ $ERROR ]; then
		for i in {1..3}; do
			echo -n "."
			sleep 1
		done
	fi
done
echo "done"

echo "Creating jBoss prepack /jbpp data volume container"
if [ ! -f bc_jbossprepack-R4.7.0.zip ]; then
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_jbossprepack-R4.7.0.zip
fi
mkdir jbpp
docker run --name jbpp -v $(pwd)/jbpp:/jbpp busybox true
docker run --rm -v $(pwd)/bc_jbossprepack-R4.7.0.zip:/pp.zip --volumes-from jbpp busybox unzip /pp.zip -d /jbpp
cp ojdbc7.jar jbpp/jboss-4.2.3.GA/server/coord/coordConfig/database/oracle-libs

echo "Creating SwiftMQ prepack /smqpp data volume container"
if [ ! -f bc_swiftmqprepack-R4.7.0.zip ]; then
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_swiftmqprepack-R4.7.0.zip
fi
mkdir smqpp
docker run --name smqpp -v $(pwd)/smqpp:/smqpp busybox true
docker run --rm -v $(pwd)/bc_swiftmqprepack-R4.7.0.zip:/pp.zip --volumes-from smqpp busybox unzip /pp.zip -d /smqpp

echo "Creating database schemas"
docker run --rm -v $(pwd)/db:/setup --volumes-from jbpp --link orcl:db guywithnose/sqlplus /setup/install

echo "Creating HpDoc heap"
docker run --rm -v $(pwd)/heap:/setup --volumes-from jbpp --link orcl:db tifayuki/java:7 /setup/create

echo "Installing the jBoss & SwiftMQ packages in a base Java image"
docker run --name base -v $(pwd)/setup:/setup --volumes-from jbpp --volumes-from smqpp tifayuki/java:7 /setup/install
docker commit base coord:base
docker rm base
echo "Removing existing Coordinator container & image"
docker stop coord
docker rm coord
docker rmi coord
echo "Building the new coord image"
docker build -t coord coord
echo "Removing the intermediairy Java image"
docker rmi coord:base

echo "Removing the data volumes"
docker rm -v jbpp
rm -rf jbpp
docker rm -v smqpp
rm -rf smqpp

echo ""
echo "Done. Now: $(date) - Started: $START"
RUN="docker run --name coord -dP --link orcl:db coord"
echo "Starting a Coordinator container now, using: $RUN"
$RUN
echo "See: docker logs coord"
