FROM tomcat:8.5-jre8
MAINTAINER Camptocamp "info@camptocamp.com"

COPY temp ${CATALINA_HOME}/temp
RUN echo "tomcat.util.scan.StandardJarScanFilter.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    echo "org.apache.catalina.startup.TldConfig.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    echo "tomcat.util.scan.DefaultJarScanner.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    apt-get update && \
    apt-get upgrade --yes && \
    apt-get install -y --no-install-recommends maven openjdk-8-jdk-headless vim && \
    mkdir ${CATALINA_HOME}/extlib && \
    cd temp && \
    mvn dependency:copy-dependencies -DoutputDirectory=${CATALINA_HOME}/extlib/ && \
    mvn package && cp target/tomcat-logstash-1.0.jar ${CATALINA_HOME}/extlib/ && \
    cd .. && \
    rm -r temp/target && \
    perl -0777 -i -pe 's/(<Valve className="org.apache.catalina.valves.AccessLogValve"[^>]*>)/<Valve className="ch.qos.logback.access.tomcat.LogbackValve" quiet="true"\/>/s' ${CATALINA_HOME}/conf/server.xml && \
    apt-get remove --purge -y maven openjdk-8-jdk-headless && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* ~/.m2 && \
    perl -0777 -i -pe 's/<\/Context>/<Resources cachingAllowed="true" cacheMaxSize="102400"\/><\/Context>/' ${CATALINA_HOME}/conf/context.xml && \
    perl -0777 -i -pe 's/assistive_technologies/#assistive_technologies/' /etc/java-8-openjdk/accessibility.properties && \
    perl -0777 -i -pe 's/securerandom.source=file:\/dev\/random/securerandom.source=file:\/dev\/urandom/' /etc/java-8-openjdk/security/java.security
RUN rm -r ${CATALINA_HOME}/webapps/* && \
    mkdir -p /usr/local/tomcat/conf/Catalina /usr/local/tomcat/work/Catalina && \
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
