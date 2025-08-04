# Build go-librespot
FROM ubuntu:22.04 AS go-librespot-builder

ARG GO_LIBRESPOT_VERSION=0.2.0

WORKDIR /code

RUN apt-get update && apt-get install -y golang-1.23-go libogg-dev libvorbis-dev libasound2-dev git

RUN git clone --branch v${GO_LIBRESPOT_VERSION} --depth 1 https://github.com/devgianlu/go-librespot.git go-librespot-code

WORKDIR go-librespot-code
RUN git status

# Cubic volume control
RUN sed -i 's/volume := out.volume \* out.volume/volume := out.volume \* out.volume \* out.volume/' output/driver-pipe.go

RUN /usr/lib/go-1.23/bin/go mod download

RUN /usr/lib/go-1.23/bin/go build -v ./cmd/daemon


# Build librespot
FROM ubuntu:22.04 AS librespot-builder

WORKDIR /code

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    cargo \
#    gstreamer1.0-plugins-base libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-good libgstreamer-plugins-good1.0-dev \
    libasound2-dev libasound2-dev pkg-config portaudio19-dev libpulse-dev libjack-dev libjack-dev libsdl2-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG LIBRESPOT_VERSION=0.6.0
#COPY build_librespot.sh /
#RUN /build_librespot.sh ${LIBRESPOT_VERSION}

RUN git clone --branch v${LIBRESPOT_VERSION} --depth 1 https://github.com/librespot-org/librespot.git librespot-code
WORKDIR librespot-code
RUN git status
RUN cargo build --release -Z sparse-registry


# Build librespot-java
FROM ubuntu:22.04 AS librespot-java-builder

WORKDIR /code

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    wget \
    maven \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG LIBRESPOT_JAVA_VERSION=1.6.3
#COPY build_librespot-java.sh /
#RUN /build_librespot-java.sh ${LIBRESPOT_JAVA_VERSION}

#RUN wget "https://github.com/librespot-org/librespot-java/releases/download/v${LIBRESPOT_JAVA_VERSION}/librespot-player-${LIBRESPOT_JAVA_VERSION}.jar"
#RUN wget "https://github.com/librespot-org/librespot-java/releases/download/v${LIBRESPOT_JAVA_VERSION}/librespot-api-${LIBRESPOT_JAVA_VERSION}.jar"
#RUN mv librespot-player-${LIBRESPOT_JAVA_VERSION}.jar /librespot-player.jar

RUN git clone --depth 1 --branch "v${LIBRESPOT_JAVA_VERSION}" https://github.com/librespot-org/librespot-java.git
WORKDIR librespot-java
RUN sed -i 's/<Console name="console" target="SYSTEM_OUT">/<Console name="console" target="SYSTEM_ERR">/' api/src/main/resources/log4j2.xml
RUN sed -i 's/<Console name="console" target="SYSTEM_OUT">/<Console name="console" target="SYSTEM_ERR">/' lib/src/main/resources/log4j2.xml
#RUN sed -i 's/if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/volumeNorm = (float) Math.pow(volumeNorm, 3) \/ 2;\n        if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/' player/src/main/java/xyz/gianlu/librespot/player/mixing/AudioSink.java
RUN sed -i 's/if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/volumeNorm = (float) Math.pow(volumeNorm, 3);\n        if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/' player/src/main/java/xyz/gianlu/librespot/player/mixing/AudioSink.java

RUN cat player/src/main/java/xyz/gianlu/librespot/player/mixing/AudioSink.java api/src/main/resources/log4j2.xml lib/src/main/resources/log4j2.xml

#COPY allcerts.patch /
#RUN git apply /allcerts.patch

#COPY skip_audio4-gm-fb.patch /
#RUN git apply /skip_audio4-gm-fb.patch

COPY skip_audio4-gm-fb_and_cdnfix.patch /
RUN git apply /skip_audio4-gm-fb_and_cdnfix.patch

#COPY cdnfix.patch /
#RUN git apply /cdnfix.patch

RUN git diff

RUN mvn clean package
RUN cp ./player/target/librespot-player-${LIBRESPOT_JAVA_VERSION}*.jar /librespot-player.jar


# Build snapcast
FROM ubuntu:22.04 AS snapcast-builder

WORKDIR /code

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    cmake \
    g++ \
    libboost-all-dev \
    libasound2-dev libpulse-dev libvorbisidec-dev libvorbis-dev libopus-dev libflac-dev libsoxr-dev alsa-utils libavahi-client-dev avahi-daemon libexpat1-dev libssl-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG SNAPCAST_VERSION=0.31.0
#COPY build_snapcast.sh /
#RUN /build_snapcast.sh ${SNAPCAST_VERSION}

RUN git clone --branch v${SNAPCAST_VERSION} --depth 1 https://github.com/badaix/snapcast.git snapcast
WORKDIR snapcast
RUN mkdir -p build
RUN git status
RUN cd build && cmake .. && cmake --build .

RUN find . -type f


# Build snapweb
FROM ubuntu:22.04 AS snapweb-builder

WORKDIR /code

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget unzip \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG SNAPWEB_VERSION=0.8.0

WORKDIR /code/snapweb
RUN wget https://github.com/badaix/snapweb/releases/download/v${SNAPWEB_VERSION}/snapweb.zip
RUN unzip snapweb.zip
RUN rm snapweb.zip


# Build actual image
FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libvorbis0a libvorbisenc2 \
    libflac8 \
    libopus0 \
    libsoxr0 \
    libasound2 \
    libavahi-client3 \
    libpulse0 \
    nano \
    less \
    openjdk-17-jre-headless \
    python3 python3-pip \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install websocket-client requests

# Install go-librespot
COPY --from=go-librespot-builder /code/go-librespot-code/daemon /usr/local/bin/go-librespot

# Install librespot
COPY --from=librespot-builder /code/librespot-code/target/release/librespot /usr/local/bin/

# Install librespot-java
COPY --from=librespot-java-builder /librespot-player.jar /librespot-player.jar
COPY librespot-player.sh /librespot-player.sh

# Install snapcast
COPY --from=snapcast-builder /code/snapcast/bin/snapserver /usr/bin/snapserver
COPY --from=snapcast-builder /code/snapcast/bin/snapclient /usr/bin/snapclient
COPY --from=snapcast-builder /code/snapcast/server/etc/snapweb /usr/share/snapserver/snapweb

# Install snapweb
COPY --from=snapweb-builder /code/snapweb/ /usr/share/snapserver/snapweb/

RUN useradd --system --uid 666 -M --shell /usr/sbin/nologin snapcast && \
    mkdir -p /home/snapcast/.config && \
    chown snapcast:snapcast -R /home

RUN mkdir -p /go-librespot{1,2,3}
COPY go-librespot-config1.yml /go-librespot1/config.yml
COPY go-librespot-config2.yml /go-librespot2/config.yml
COPY go-librespot-config3.yml /go-librespot3/config.yml
RUN chown -R snapcast /go-librespot*

RUN mkdir -p /var/cache/snapcast/librespot && \
    chown -R snapcast /var/cache/snapcast

COPY config.toml /config.toml
RUN chown 666:666 /config.toml

USER snapcast

EXPOSE 1704
EXPOSE 1705

#VOLUME /data
#WORKDIR /data

VOLUME /home/snapcast/.config/snapserver
VOLUME /var/cache/snapcast

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
