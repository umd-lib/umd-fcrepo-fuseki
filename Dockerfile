# Dockerfile for the generating the Fuseki image
#
# To build:
#
# docker build -t docker.lib.umd.edu/fcrepo-fuseki:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.

# generic Fuseki image
FROM eclipse-temurin:8-jdk-jammy AS fuseki

ENV FUSEKI_VERSION=2.3.1
ENV FUSEKI_URL=https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-${FUSEKI_VERSION}.tar.gz
ENV FUSEKI_HOME=/opt/apache-jena-fuseki-${FUSEKI_VERSION}
ENV FUSEKI_BASE=/var/opt/fuseki
ENV FUSEKI_DATA_DIR=$FUSEKI_BASE/databases

# Download and install Fuseki.
# We need to run this as three separate commands instead of a single
# "curl ... | tar xvzf - ..." pipeline due to some problems with how
# QEMU handles pipes and sub-processes when running multi-platform
# Docker builds on Kubernetes.
RUN curl -Ls "$FUSEKI_URL" -o /tmp/fuseki.tar.gz
RUN gzip -d /tmp/fuseki.tar.gz
RUN tar xvf /tmp/fuseki.tar --directory /opt
RUN rm /tmp/fuseki.tar

RUN mkdir -p "$FUSEKI_BASE"/{DB,logs}

VOLUME /var/opt/fuseki
EXPOSE 3030

WORKDIR $FUSEKI_HOME
CMD ["./fuseki", "run"]

# UMD-specific configuration
FROM fuseki

# Allow JRE to use up to 75% of the RAM in the container
ENV JAVA_OPTIONS="-XX:MaxRAMPercentage=75.0"

COPY configuration/* $FUSEKI_BASE/configuration/
COPY shiro.ini $FUSEKI_BASE/
