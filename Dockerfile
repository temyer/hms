FROM openjdk:11.0.13-jre-slim-buster

ENV HADOOP_VERSION=3.2.1
ENV METASTORE_VERSION=3.1.2
ENV JDBC_POSTGRES_VERSION=42.3.1

ENV HADOOP_HOME=/usr/local/hadoop
ENV HIVE_HOME=/usr/local/metastore

RUN apt-get update && \
    apt-get install wget -y && \
    wget https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz -O - | tar -xz && \
    mv apache-hive-metastore-3.1.2-bin ${HIVE_HOME} && \
    wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O - | tar -xz && \
    mv hadoop-3.2.1 ${HADOOP_HOME} && \
    wget https://repo1.maven.org/maven2/org/postgresql/postgresql/${JDBC_POSTGRES_VERSION}/postgresql-${JDBC_POSTGRES_VERSION}.jar && \
    mv postgresql-${JDBC_POSTGRES_VERSION}.jar ${HIVE_HOME}/lib/

RUN rm ${HIVE_HOME}/lib/guava-19.0.jar && \
    rm -f ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar && \
    cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/ && \
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.1.jar ${HIVE_HOME}/lib/ && \
    cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar ${HIVE_HOME}/lib/ && \
    cd ${HADOOP_HOME}/share/hadoop/common/lib && \
    wget https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-web/2.17.1/log4j-web-2.17.1.jar

COPY conf/metastore-site.xml ${HIVE_HOME}/conf
COPY scripts/entrypoint.sh /entrypoint.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT [ "bash", "entrypoint.sh" ]
