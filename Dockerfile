FROM tomcat:8.5-jre8
MAINTAINER Camptocamp "info@camptocamp.com"

COPY temp/pom.xml ${CATALINA_HOME}/temp/pom.xml
RUN echo "tomcat.util.scan.StandardJarScanFilter.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    echo "org.apache.catalina.startup.TldConfig.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    echo "tomcat.util.scan.DefaultJarScanner.jarsToSkip=*" >> ${CATALINA_HOME}/conf/catalina.properties && \
    apt-get update && \
    apt-get install -y --no-install-recommends maven && \
    mkdir ${CATALINA_HOME}/extlib && \
    (cd temp; mvn dependency:copy-dependencies -DoutputDirectory=${CATALINA_HOME}/extlib/) && \
    perl -0777 -i -pe 's/(<Valve className="org.apache.catalina.valves.AccessLogValve"[^>]*>)/<Valve className="ch.qos.logback.access.tomcat.LogbackValve" quiet="true"\/>/s' ${CATALINA_HOME}/conf/server.xml && \
    apt-get remove --purge -y maven && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* ~/.m2 && \
    perl -0777 -i -pe 's/<\/Context>/<Resources cachingAllowed="true" cacheMaxSize="102400"\/><\/Context>/' ${CATALINA_HOME}/conf/context.xml
RUN rm -r ${CATALINA_HOME}/webapps/*

COPY . ${CATALINA_HOME}

ENV TOMCAT_LOG_LEVEL INFO
ENV TOMCAT_LOG_TYPE classic
