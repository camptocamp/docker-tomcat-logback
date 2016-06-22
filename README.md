# Docker image for tomcat with logback integration

Based on the official tomcat image, but with logs using logback.
Access logs are going to stdout and the other logs are going to stderr.

Some environment variables are available to tune the logs:

* TOMCAT_LOG_LEVEL: Set the log level.
* TOMCAT_LOG_TYPE: If set to `json`, the logs will be formatted in a JSON suitable for logstash.

If you want to change the way things are logged, change the ${CATALINA_HOME}/conf/logback-custom.xml file.

Other changes compared the official tomcat image:

* All the default webapps are removed.
* TLD and JAR scanners are disabled (faster startup).
* Resources caching is properly configured.
