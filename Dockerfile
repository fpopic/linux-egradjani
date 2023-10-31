FROM ubuntu:22.04

RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    && apt-get install -y libnss3-tools libccid pcsc-tools opensc \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/.pki/nssdb \
    && certutil -d /tmp/.pki/nssdb -N --empty-password\
    && chmod 777 /tmp/.pki/nssdb/pkcs11.txt

CMD ["modutil -dbdir sql:/tmp/.pki/nssdb -list"]
