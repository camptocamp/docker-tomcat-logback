FROM maven:3-openjdk-11 AS builder

COPY temp /tmp/temp
RUN mkdir /tmp/extlib && \
    cd /tmp/temp && \
    mvn dependency:copy-dependencies -DoutputDirectory=/tmp/extlib/ && \
    mvn package && \
    cp target/tomcat-logstash-1.0.jar /tmp/extlib/

FROM tomcat:10.0-jdk11-openjdk-slim AS runner
LABEL maintainer="Camptocamp <info@camptocamp.com>"

COPY --from=builder /tmp/extlib/ ${CATALINA_HOME}/extlib/

RUN perl -0777 -i -pe 's/(<Valve className="org.apache.catalina.valves.AccessLogValve"[^>]*>)/<Valve className="ch.qos.logback.access.tomcat.LogbackValve" quiet="true"\/>/s' ${CATALINA_HOME}/conf/server.xml && \
    echo "tomcat.util.scan.StandardJarScanFilter.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    echo "org.apache.catalina.startup.TldConfig.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    echo "tomcat.util.scan.DefaultJarScanner.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    perl -0777 -i -pe 's/<\/Context>/<Resources cachingAllowed="true" cacheMaxSize="102400"\/><\/Context>/' ${CATALINA_HOME}/conf/context.xml

RUN mkdir --parent /usr/local/tomcat/conf/Catalina /usr/local/tomcat/work/Catalina && \
    chmod -R g+rwx /usr/local/tomcat/conf/Catalina /usr/local/tomcat/work && \
    chgrp -R root /usr/local/tomcat/conf/Catalina /usr/local/tomcat/work && \
    chmod g+r /usr/local/tomcat/conf/*

COPY . ${CATALINA_HOME}

ENV DEFAULT_LOG_LEVEL=INFO \
    TOMCAT_LOG_LEVEL=INFO \
    SENTRY_LOG_LEVEL=ERROR \
    SENTRY_REPORTING_LOG_LEVEL=WARN \
    TOMCAT_LOG_TYPE=classic \
    JAVA_OPTS=-Dsun.net.inetaddr.ttl=30
