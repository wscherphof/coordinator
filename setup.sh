START=$(date)

echo "Starting an Oracle container"
# run an Oracle container (without removing any existing, since that may just hurt too much)
docker run --privileged --name orcl -d wscherphof/oracle-12c 2> /dev/null
# in case it already existed and was stopped
docker start orcl
echo -n "Wait while ensuring the database has started..."
ERROR=true
while [ $ERROR ]; do
	ERROR=$(docker run --name connect --link orcl:db -v $(pwd)/connect:/connect guywithnose/sqlplus /connect | grep ERROR)
	docker rm -v connect > /dev/null
	if [ $ERROR ]; then
		for i in {1..3}; do
			echo -n "."
			sleep 1
		done
	fi
done
echo "done"

echo "Creating jBoss prepack /jbpp data volume container"
if [ ! -f jbpp/bc_jbossprepack-R4.7.0.zip ]; then
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_jbossprepack-R4.7.0.zip
fi
mkdir jbpp
docker run --name jbpp -v $(pwd)/jbpp:/jbpp busybox true
docker run --rm -v $(pwd)/bc_jbossprepack-R4.7.0.zip:/pp.zip --volumes-from jbpp busybox unzip /pp.zip -d /jbpp
cp ojdbc7.jar jbpp/jboss-4.2.3.GA/server/coord/coordConfig/database/oracle-libs

echo "Creating SwiftMQ prepack /smqpp data volume container"
if [ ! -f smqpp/bc_swiftmqprepack-R4.7.0.zip ]; then
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_swiftmqprepack-R4.7.0.zip
fi
mkdir smqpp
docker run --name smqpp -v $(pwd)/smqpp:/smqpp busybox true
docker run --rm -v $(pwd)/bc_swiftmqprepack-R4.7.0.zip:/pp.zip --volumes-from smqpp busybox unzip /pp.zip -d /smqpp

echo "Creating database schemas"
docker build -t setup/db db
docker run --rm --volumes-from jbpp --link orcl:db setup/db
docker rmi setup/db

echo "Creating HpDoc heap"
docker build -t setup/heap heap
docker run --rm --volumes-from jbpp --link orcl:db setup/heap
docker rmi setup/heap

echo "Installing the jBoss & SwiftMQ packages in a Java image"
docker run --name jboss --volumes-from jbpp tifayuki/java:7 /bin/bash -c "mkdir /app && mkdir /app/ismobile && cp -r /jbpp/* /app/ismobile"
docker commit jboss setup/jboss
docker rm jboss
docker run --name swift --volumes-from smqpp setup/jboss /bin/bash -c "cp -r /smqpp/* /app/ismobile"
docker commit swift setup/swift
docker rm swift
echo "Removing existing Coordinator container & image"
docker stop coord
docker rm coord
docker rmi coord
echo "Building the new coord image"
docker build -t coord coord
echo "Removing the intermediairy Java images"
docker rmi setup/jboss
docker rmi setup/swift

echo "Removing the data volumes"
docker rm -v jbpp
rm -rf jbpp
docker rm -v smqpp
rm -rf smqpp

echo ""
echo "Done. Now: $(date) - Started: $START"
echo "Starting a Coordinator container now:"
docker run --name coord -dP --link orcl:db coord
echo "See: docker logs coord"
