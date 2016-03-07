# AUTHOR:         João Ribeiro <jonnybgod@gmail.com>
# DESCRIPTION:    jonnybgod/filebeat

FROM frolvlad/alpine-glibc:alpine-3.3_glibc-2.23
MAINTAINER João Ribeiro <jonnybgod@gmail.com> 

ENV VERSION=1.1.2 PLATFORM=x86_64
ENV FILENAME=filebeat-${VERSION}-${PLATFORM}.tar.gz 

# Environment variables
ENV FILEBEAT_HOME /opt/filebeat-${VERSION}-${PLATFORM}
ENV PATH $PATH:${FILEBEAT_HOME}

WORKDIR /opt/

RUN apk add --no-cache python curl

RUN curl -sL https://download.elastic.co/beats/filebeat/${FILENAME} | tar xz -C .

ADD filebeat.yml ${FILEBEAT_HOME}/filebeat.yml
ADD docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]