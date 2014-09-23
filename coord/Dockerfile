FROM setup/swift
MAINTAINER Wouter Scherphof <wouter.scherphof@ismobile.com>

RUN cp /app/ismobile/jboss-4.2.3.GA/server/all/lib/jbossws-* /app/ismobile/jboss-4.2.3.GA/server/default/lib

RUN rm /app/ismobile/jboss-4.2.3.GA/server/coord/lib/ojdbc6.jar
RUN cp /app/ismobile/jboss-4.2.3.GA/server/coord/coordConfig/database/oracle-libs/ojdbc7.jar /app/ismobile/jboss-4.2.3.GA/server/coord/lib

ENV UID_DB coord
ENV PWD_DB coord
ENV UID_JMS jms
ENV PWD_JMS jms
ENV UID_SCHED sched
ENV PWD_SCHED sched

EXPOSE 8085

ADD start /start
CMD /start
