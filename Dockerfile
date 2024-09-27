FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN yum update
RUN yum install httpd -y
COPY myindex.html /var/www/html/myindex.html
WORKDIR /var/www/html
ENTRYPOINT ["/usr/sbin/httpdctl"]
CMD ["-D", "FOREGROUND"]
EXPOSE 80
