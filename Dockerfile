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

# Create entrypoint script inside the image
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo 'SOURCE_DIR="/mnt/cpack-exercise"' >> /entrypoint.sh && \
    echo 'BUILD_DIR="/tmp/build"' >> /entrypoint.sh && \
    echo 'if [ ! -d "$SOURCE_DIR" ]; then' >> /entrypoint.sh && \
    echo '    echo "Error: Source directory $SOURCE_DIR not found. Did you mount the volume?"' >> /entrypoint.sh && \
    echo '    exit 1' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo 'echo "Setting up build environment..."' >> /entrypoint.sh && \
    echo 'mkdir -p "$BUILD_DIR"' >> /entrypoint.sh && \
    echo 'rsync -av --exclude "build" "$SOURCE_DIR/" "$BUILD_DIR/"' >> /entrypoint.sh && \
    echo 'cd "$BUILD_DIR"' >> /entrypoint.sh && \
    echo 'echo "Configuring project..."' >> /entrypoint.sh && \
    echo 'cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .' >> /entrypoint.sh && \
    echo 'echo "Building project..."' >> /entrypoint.sh && \
    echo 'cmake --build build' >> /entrypoint.sh && \
    echo 'echo "Creating packages..."' >> /entrypoint.sh && \
    echo 'cd build' >> /entrypoint.sh && \
    echo 'cpack -G TGZ' >> /entrypoint.sh && \
    echo 'cpack -G DEB' >> /entrypoint.sh && \
    echo 'echo "Copying packages to host..."' >> /entrypoint.sh && \
    echo 'cp *.tar.gz "$SOURCE_DIR/"' >> /entrypoint.sh && \
    echo 'cp *.deb "$SOURCE_DIR/"' >> /entrypoint.sh && \
    echo 'echo "Done! Packages are available in $SOURCE_DIR"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
