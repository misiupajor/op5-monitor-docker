FROM centos:6
MAINTAINER Misiu Pajor <misiu.pajor@op5.com>

# Install OP5 Monitor 7.3.15
RUN yum -y install wget openssh-server \
    && wget https://d2ubxhm80y3bwr.cloudfront.net/Downloads/op5_monitor_archive/op5-monitor-7.3.15-20170707.tar.gz -O /tmp/op5-software.tar.gz \
    && mkdir -p /tmp/op5-monitor && tar -zxf /tmp/op5-software.tar.gz -C /tmp/op5-monitor --strip-components=1 \
    && cd /tmp/op5-monitor && ./install.sh --silent \
    && rm -f /tmp/op5-software.tar.gz \
    && cd /tmp && rm -rf /tmp/op5-monitor \
    && yum clean all

# Replace the system() source because inside Docker we can't access /proc/kmsg.
# https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
RUN sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

# HTTPD
EXPOSE 80 443

# NRPE agent
EXPOSE 5666

# Merlin
EXPOSE 15551

# SSH
EXPOSE 22

 #SNMPD
EXPOSE 162/tcp 162/udp

ADD entrypoint.d /root/
RUN chmod +x /root/entrypoint.d/entrypoint.sh
CMD ["/root/entrypoint.d/entrypoint.sh"]
