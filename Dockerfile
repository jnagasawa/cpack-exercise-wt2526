FROM ubuntu:24.04

# Install a few dependencies
RUN apt-get -qq update && \
    apt-get -qq -y install \
        build-essential \
        cmake \
        git \
        libboost-all-dev \
        wget \
        libdeal.ii-dev \
        vim \
        tree \
        lintian \
        tree \
        lintian \
        unzip \
        rsync
        
# Get, unpack, build, and install yaml-cpp        
RUN mkdir software && cd software && \
    wget https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.6.3.zip && unzip yaml-cpp-0.6.3.zip && \
    cd yaml-cpp-yaml-cpp-0.6.3 && mkdir build && cd build && \
    cmake -DYAML_BUILD_SHARED_LIBS=ON .. && make -j4 && make install    
    
# This is some strange Docker feature. Normally, you don't need to add /usr/local to these
ENV LIBRARY_PATH $LIBRARY_PATH:/usr/local/lib/
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib/
ENV PATH $PATH:/usr/local/bin/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
