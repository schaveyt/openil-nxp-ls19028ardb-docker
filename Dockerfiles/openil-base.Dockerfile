FROM ubuntu:20.04

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="registry.gear.ge.com/pcs/openil-base"
LABEL org.label-schema.description="OpenIL Build Environment"
LABEL org.label-schema.url="https://registry.gear.ge.com/pcs/openil-base"
LABEL org.label-schema.vcs-url="https://github.build.ge.com/pcs/openil-base"
LABEL org.label-schema.vcs-ref=TBD
LABEL org.label-schema.vendor=TBD
LABEL org.label-schema.version="2.0"
LABEL org.label-schema.docker.cmd="docker image build \
    --file Dockerfiles/OpenIL.Dockerfile \
    --build-arg http_proxy=http://PITC-Zscaler-Americas-Cincinnati3PR.proxy.corporate.ge.com:80 \
    --build-arg HTTP_PROXY=http://PITC-Zscaler-Americas-Cincinnati3PR.proxy.corporate.ge.com:80 \
    --build-arg https_proxy=http://PITC-Zscaler-Americas-Cincinnati3PR.proxy.corporate.ge.com:80 \
    --build-arg HTTPS_PROXY=http://PITC-Zscaler-Americas-Cincinnati3PR.proxy.corporate.ge.com:80 \
    --build-arg proxy=http://pitc-zscaler-americas-alpharetta3pr.proxy.corporate.ge.com:80 \
    --build-arg PROXY=http://pitc-zscaler-americas-alpharetta3pr.proxy.corporate.ge.com:80 \
    --build-arg no_proxy=localhost,::1,127.0.0.1,.ge.com,10.0.2.2,github.build.ge.com \
    --build-arg NO_PROXY=localhost,::1,127.0.0.1,.ge.com,10.0.2.2,github.build.ge.com \
    --tag=registry.gear.ge.com/pcs/openil-base:<tag> ."

# disable the certifcate check for wget so as to prevent the nxp download files from erroring out.
RUN echo "check_certificate = off" >> ~/.wgetrc

# disable all commandline interactions
ENV DEBIAN_FRONTEND=noninteractive

# Prepare the environment. All of this must be installed in order for the build tools and environment to work.
RUN apt-get update
RUN apt-get install -y git-all

# this is to disable the ssl verification that prevents several components from being downloaded.
RUN git config --global http.sslverify false && \
    git config --global http.postBuffer 1048576000


# Create and change directory to /opt folder
WORKDIR /opt

# Clone the public OpenIL git repo to /opt/openil
RUN git clone https://github.com/openil/openil.git
WORKDIR /opt/openil

# checkout to the 2021.04 v1.11 release
RUN git checkout OpenIL-v1.11-202104 -b OpenIL-v1.11-202104

RUN apt-get install -y curl sudo wget

# Run below command to check and install these packages required automatically.
RUN sudo ./env_setup.sh

WORKDIR /usr/project/src




