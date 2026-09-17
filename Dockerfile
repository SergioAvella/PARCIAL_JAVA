FROM tomcat:10.1-jdk17

# Eliminar las aplicaciones por defecto de Tomcat para limpiar el servidor
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar el contenido de tu proyecto web al ROOT de Tomcat para que corra en la raíz
COPY . /usr/local/tomcat/webapps/ROOT/

# Exponer el puerto que usa Tomcat
EXPOSE 8080

# Comando para iniciar Tomcat en primer plano
CMD ["catalina.sh", "run"]