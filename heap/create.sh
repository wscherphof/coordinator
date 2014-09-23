ORCL=${DB_PORT_1521_TCP_ADDR}:${DB_PORT_1521_TCP_PORT}:${DB_ENV_ORACLE_SID}
DATABASE=/jbpp/jboss-4.2.3.GA/server/coord/coordConfig/database

CMD="java -cp ${DATABASE}/oracle-libs/ojdbc7.jar:${DATABASE}/ism_tools/hpadmin-R2.1.20.jar com.ismobile.hpadmin.Main --url=jdbc:oracle:thin:coord/coord@${ORCL} --heap --new=${DATABASE}/ism_setup/heapdef-examples/heapdef-default.xml DEAFAULT"

echo $CMD

$CMD
