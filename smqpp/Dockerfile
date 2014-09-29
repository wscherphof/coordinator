FROM busybox
MAINTAINER Wouter Scherphof <wouter.scherphof@ismobile.com>

ADD bc_swiftmqprepack-R4.7.0.zip /smqpp/bc_swiftmqprepack-R4.7.0.zip
RUN unzip /smqpp/bc_swiftmqprepack-R4.7.0.zip -d /smqpp && rm /smqpp/bc_swiftmqprepack-R4.7.0.zip

VOLUME /smqpp
