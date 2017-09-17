FROM centos:6
MAINTAINER Misiu Pajor <misiu.pajor@op5.com>

# Install OP5 Monitor (currently v7.3.15)
RUN yum -y install wget openssh-server python-requests \
    && wget https://d2ubxhm80y3bwr.cloudfront.net/Downloads/op5_monitor_archive/op5-monitor-7.3.15-20170707.tar.gz -O /tmp/op5-software.tar.gz \
    && mkdir -p /tmp/op5-monitor && tar -zxf /tmp/op5-software.tar.gz -C /tmp/op5-monitor --strip-components=1 \
    && cd /tmp/op5-monitor && ./install.sh --silent \
    && rm -f /tmp/op5-software.tar.gz \
    && cd /tmp && rm -rf /tmp/op5-monitor \
    && yum clean all

# Replace the system() source because inside Docker we can't access /proc/kmsg.
# https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
RUN sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf \
	&& sed -i -E '/\proc\/kmsg/ s/^#*/#/' /etc/syslog-ng/syslog-ng.conf

# Expose ports that are required by OP5
EXPOSE 80 443 5666 15551 22 161/tcp 162/udp

COPY /entrypoint.d /usr/libexec/entrypoint.d/
RUN chmod +x /usr/libexec/entrypoint.d/hooks/* \
	&& chmod +x /usr/libexec/entrypoint.d/entrypoint.sh \ 
	&& chmod +x /usr/libexec/entrypoint.d/hooks.py
CMD ["/usr/libexec/entrypoint.d/entrypoint.sh"]
