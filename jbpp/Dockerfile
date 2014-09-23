FROM busybox
MAINTAINER Wouter Scherphof <wouter.scherphof@ismobile.com>

# ADD http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_jbossprepack-R4.7.0.zip /jbpp/bc_jbossprepack-R4.7.0.zip
ADD bc_jbossprepack-R4.7.0.zip /jbpp/bc_jbossprepack-R4.7.0.zip
RUN unzip /jbpp/bc_jbossprepack-R4.7.0.zip -d /jbpp && rm /jbpp/bc_jbossprepack-R4.7.0.zip

ADD ojdbc7.jar /jbpp/jboss-4.2.3.GA/server/coord/coordConfig/database/oracle-libs/ojdbc7.jar

VOLUME /jbpp
