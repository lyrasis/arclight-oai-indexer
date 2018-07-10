FROM solr:7.4
LABEL maintainer="mark.cooper@lyrasis.org"

RUN cd /opt/solr && \
    wget -O arclight-master.zip https://github.com/sul-dlss/arclight/archive/master.zip && \
    unzip arclight-master.zip && \
    mkdir -p /opt/solr/arclight/solr && \
    cp -r /opt/solr/arclight-master/solr /opt/solr/arclight
