CLASSPATH=${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar:${CATALINA_HOME}/conf

for jar in ${CATALINA_HOME}/lib/* ${CATALINA_HOME}/extlib/*
do
    CLASSPATH=${CLASSPATH}:$jar
done

UMASK="0022"
