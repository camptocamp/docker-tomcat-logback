CLASSPATH=${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar

echo "TOMCAT_LOG_TYPE=${TOMCAT_LOG_TYPE}"
if [ "${TOMCAT_LOG_TYPE}" = "json" ]
then
    CLASSPATH=${CLASSPATH}:${CATALINA_HOME}/conf/log.json/
else
    CLASSPATH=${CLASSPATH}:${CATALINA_HOME}/conf/log.classic/
fi

for jar in ${CATALINA_HOME}/lib/* ${CATALINA_HOME}/extlib/*
do
    CLASSPATH=${CLASSPATH}:$jar
done

UMASK="0022"
