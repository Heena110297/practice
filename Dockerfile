FROM tomcat:alpine

LABEL maintainer="Heena Mittal"

RUN wget -O /usr/local/tomcat/webapps/launchstation04.war -U admin:Learning http://192.168.18.90:8082/artifactory/demoArtifactory/com/nagarro/devops-tools/devops/demo/0.0.1-SNAPSHOT/demo-0.0.1-SNAPSHOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
