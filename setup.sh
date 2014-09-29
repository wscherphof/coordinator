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
  cd jbpp
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_jbossprepack-R4.7.0.zip
  cd ..
fi
docker build -t setup/jbpp jbpp
docker run --name jbpp setup/jbpp true

echo "Creating SwiftMQ prepack /smqpp data volume container"
if [ ! -f smqpp/bc_swiftmqprepack-R4.7.0.zip ]; then
  cd smqpp
  wget http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_swiftmqprepack-R4.7.0.zip
  cd ..
fi
docker build -t setup/smqpp smqpp
docker run --name smqpp setup/smqpp true

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

echo "Removing the data volume containers & images"
docker rm -v jbpp
docker rmi setup/jbpp
docker rm -v smqpp
docker rmi setup/smqpp

echo ""
echo "Done. Now: $(date) - Started: $START"
echo "Starting a Coordinator container now:"
docker run --name coord -dP --link orcl:db coord
echo "See: docker logs coord"
