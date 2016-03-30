FROM alpine:3.3

ENV LANG C.UTF-8

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:$JAVA_HOME/bin
ENV LOGSTASH_PKG_NAME logstash-2.3.0

ENV JAVA_VERSION 8u77
ENV JAVA_ALPINE_VERSION 8.77.03-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

RUN apk add --no-cache --update curl bash ca-certificates
RUN \
  ( curl -Lskj http://download.elastic.co/logstash/logstash/$LOGSTASH_PKG_NAME.tar.gz | tar zxf - ) && \
  mv $LOGSTASH_PKG_NAME /logstash 
  #&& \
  #//rm -rf $(find /logstash | egrep "(\.(exe|bat)$|sigar/.*(dll|winnt|x86-linux|solaris|ia64|freebsd|macosx))")
  
RUN \
  ( curl -Lskj http://ftp.ps.pl/pub/apache/kafka/0.8.2.2/kafka_2.10-0.8.2.2.tgz | tar zxf - ) && \
   mv kafka_2.10-0.8.2.2 /kafka && \
   apk del curl wget 

ENV PATH /logstash/bin:$PATH
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["logstash", "agent"]
