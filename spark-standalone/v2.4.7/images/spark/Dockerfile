
#
# Dockerfile for running Spark Standalone 2.4.7
#

# Initial stage to build python 3.7 from source since it is not available in
# the apt repository
FROM docker.io/bitnami/minideb:bookworm as builder

RUN install_packages wget curl unzip procps

# Install the compilation tools and libraries in a separate step to reuse the
# layer in the runtime image
RUN install_packages build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
                     libnss3-dev libssl-dev libsqlite3-dev libreadline-dev \
                     libffi-dev curl libbz2-dev

# TODO Include the certificate to allow checking the source of the environment
RUN wget --no-check-certificate https://www.python.org/ftp/python/3.7.17/Python-3.7.17.tar.xz

RUN tar -xf Python-3.7.17.tar.xz && \
    cd Python-3.7.17 && \
    ./configure --enable-optimizations --enable-shared --with-ensurepip=install && \
    make -j 4 && \
    make altinstall

# Use the bitnami minideb image to minimize the layers stored in the environment
# if we use other bitnami images
FROM docker.io/bitnami/minideb:bookworm

RUN install_packages wget curl unzip procps
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib


RUN echo "deb http://deb.debian.org/debian unstable main non-free contrib" >> /etc/apt/sources.list && \
    apt update

RUN install_packages openjdk-8-jre-headless

RUN wget --no-check-certificate https://archive.apache.org/dist/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz

RUN tar -xvzf spark-2.4.7-bin-hadoop2.7.tgz && \
    mv spark-2.4.7-bin-hadoop2.7 /opt/spark && \
    rm spark-2.4.7-bin-hadoop2.7.tgz && \
    python3.7 -m pip install pyspark==2.4.7 --break-system-packages

RUN mkdir -p /opt/spark/work && chmod a+wx /opt/spark/work && \
    mkdir -p /opt/spark/local && chmod -R a+wx /opt/spark && \
    mkdir -p /opt/spark/ivy2 && chmod -R a+wx /opt/spark && \
    ln -s /usr/local/bin/python3.7 /usr/local/bin/python

# Create the named user for spark to prevent the issue of a null pointer exception
# when the user has no name
RUN adduser --disabled-password --gecos '' --uid 1001 spark

# Add our own scripts to the container that will run the container with the
# proper environment settings
COPY scripts /opt/spark/scripts
RUN chmod +x /opt/spark/scripts/*.sh && \
    chown -R 1001:1001 /opt/spark

USER 1001

WORKDIR /opt/spark

EXPOSE 8080
EXPOSE 4040

# TODO: Setup loading the environment variables when running a command instead
# of hardcoding them in the Dockerfile
ENV SPARK_BASE_DIR /opt/spark
ENV SPARK_LOG_DIR /tmp/spark/logs
ENV SPARK_HOME /opt/spark
ENV SPARK_LOCAL_DIRS /opt/spark/local
ENV HOME /tmp/spark
ENV SPARK_NO_DEAMONIZE true
ENV SPARK_RPC_AUTHENTICATION_ENABLED no
ENV SPARK_RPC_AUTHENTICATION_SECRET ""
ENV SPARK_RPC_ENCRYPTION_ENABLED no


#ENTRYPOINT ["/opt/spark/scripts/entrypoint.sh"]
CMD ["/opt/spark/scripts/run.sh"]
