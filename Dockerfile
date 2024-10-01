FROM amazonlinux:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN yum install httpd -y
COPY myindex.html /var/www/html/myindex.html
WORKDIR /var/www/html
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-D", "FOREGROUND"]
EXPOSE 80

