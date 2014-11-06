FROM coord:base
MAINTAINER Wouter Scherphof <wouter.scherphof@ismobile.com>

# this is only to be able to start the `default` server, which we normally never do
RUN cp /app/ismobile/jboss-4.2.3.GA/server/all/lib/jbossws-* /app/ismobile/jboss-4.2.3.GA/server/default/lib

# we run in newer java version than the prepack assumes
RUN rm /app/ismobile/jboss-4.2.3.GA/server/coord/lib/ojdbc6.jar
RUN cp /app/ismobile/jboss-4.2.3.GA/server/coord/coordConfig/database/oracle-libs/ojdbc7.jar /app/ismobile/jboss-4.2.3.GA/server/coord/lib

# superuser
RUN echo ""              >> /app/ismobile/jboss-4.2.3.GA/server/coord/conf/props/users.properties
RUN echo "disp40=disp40" >> /app/ismobile/jboss-4.2.3.GA/server/coord/conf/props/users.properties
RUN echo ""              >> /app/ismobile/jboss-4.2.3.GA/server/coord/conf/props/roles.properties
RUN echo "disp40=superuser,dispatcher,sysadmin,teamadmin,loader,dataadmin,useradmin,sysaudit,woadmin" >> /app/ismobile/jboss-4.2.3.GA/server/coord/conf/props/roles.properties

# slf4j needed by submarine
# temporary; fixed in a future release of the Prepack distribution
RUN cp /app/ismobile/swiftmq_8_1_2_jmsplus/coordConfig/ism-jars/slf4j-api-1.6.1.jar     /app/ismobile/jboss-4.2.3.GA/server/coord/lib
RUN cp /app/ismobile/swiftmq_8_1_2_jmsplus/coordConfig/ism-jars/slf4j-log4j12-1.6.1.jar /app/ismobile/jboss-4.2.3.GA/server/coord/lib

ENV UID_DB coord
ENV PWD_DB coord
ENV UID_JMS jms
ENV PWD_JMS jms
ENV UID_SCHED sched
ENV PWD_SCHED sched

EXPOSE 8085

ADD start /start
CMD /start
