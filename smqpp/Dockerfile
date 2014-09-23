FROM busybox
MAINTAINER Wouter Scherphof <wouter.scherphof@ismobile.com>

# ADD http://releases.hq.ismobile.com/packages/coordinator-R4.7/bc_swiftmqprepack-R4.7.0.zip /smqpp/bc_swiftmqprepack-R4.7.0.zip
ADD bc_swiftmqprepack-R4.7.0.zip /smqpp/bc_swiftmqprepack-R4.7.0.zip
RUN unzip /smqpp/bc_swiftmqprepack-R4.7.0.zip -d /smqpp && rm /smqpp/bc_swiftmqprepack-R4.7.0.zip

VOLUME /smqpp
