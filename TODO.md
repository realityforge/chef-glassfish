* Startup domain explicitly and take control of jvm parameters similar to the way described in http://java.net/projects/glassfish/lists/dev/archive/2012-02/message/10
* Ensure JMX works as advertised. Maybe require -Djava.rmi.server.hostname=Glassfish_Server_External_IP_Address -Djava.net.preferIPv4Stack=true
