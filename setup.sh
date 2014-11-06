#!/bin/bash

START=$(date)

echo "Starting an Oracle container"
# run an Oracle container (without removing any existing, since that may just hurt too much)
docker run --privileged --name coorddb -d wscherphof/oracle-12c 2> /dev/null
# in case it already existed and was stopped
docker start coorddb
echo -n "Wait while ensuring the database has started..."
while :; do
	ERROR=$(docker run --rm --link coorddb:db -v $(pwd)/setup:/setup guywithnose/sqlplus /setup/connect | grep ERROR)
	if [ $ERROR ]; then
    echo -n "."
    sleep 1
  else
    echo "done"
    break
	fi
done

echo "Loading the prepacks in a data volume container"
mkdir pp
docker run --name pp -v $(pwd)/pp:/pp busybox true
# SwiftMQ
if [ ! -f bc_swiftmqprepack-R4.7.0.zip ]; then
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_swiftmqprepack-R4.7.0.zip
fi
mkdir pp/smq
docker run --rm -v $(pwd)/bc_swiftmqprepack-R4.7.0.zip:/pp.zip --volumes-from pp busybox unzip /pp.zip -d /pp/smq
# jBoss
if [ ! -f bc_jbossprepack-R4.7.0.zip ]; then
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_jbossprepack-R4.7.0.zip
fi
mkdir pp/jboss
docker run --rm -v $(pwd)/bc_jbossprepack-R4.7.0.zip:/pp.zip --volumes-from pp busybox unzip /pp.zip -d /pp/jboss
# also include the java 7 ojdbc jar
cp setup/ojdbc7.jar pp/jboss/jboss-4.2.3.GA/server/coord/coordConfig/database/oracle-libs

echo "Creating database schemas"
docker run --rm -v $(pwd)/db:/setup --volumes-from pp --link coorddb:db guywithnose/sqlplus /setup/install

echo "Creating HpDoc heap"
docker run --rm -v $(pwd)/heap:/setup --volumes-from pp --link coorddb:db tifayuki/java:7 /setup/create

echo "Installing the jBoss & SwiftMQ packages in a base Java image"
docker run --name base -v $(pwd)/setup:/setup --volumes-from pp tifayuki/java:7 /setup/install
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

echo "Removing the prepacks data volume"
docker rm -v pp
rm -rf pp

echo ""
echo "Done. Timer:"
echo "- Now: $(date)"
echo "- Started: $START"
echo ""

echo "To run a container: \$ docker run --name coord -d -p 8085:8085 --link coorddb:db coord"
echo "To see what the container did: \$ docker logs coord"
