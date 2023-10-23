#!/bin/bash
set -e

LIBRESPOT_JAVA_VERSION="${1}"

VARIANT="manfred"

if [ "$VARIANT" == "standard" ]; then
  apt-get install -y wget
  wget "https://github.com/librespot-org/librespot-java/releases/download/v${LIBRESPOT_JAVA_VERSION}/librespot-player-${LIBRESPOT_JAVA_VERSION}.jar"
  wget "https://github.com/librespot-org/librespot-java/releases/download/v${LIBRESPOT_JAVA_VERSION}/librespot-api-${LIBRESPOT_JAVA_VERSION}.jar"

  mv librespot-player-${LIBRESPOT_JAVA_VERSION}.jar /librespot-player.jar
else
  git clone --depth 1 --branch "v${LIBRESPOT_JAVA_VERSION}" https://github.com/librespot-org/librespot-java.git
  cd librespot-java

  # Change logging to stderr
  sed -i 's/<Console name="console" target="SYSTEM_OUT">/<Console name="console" target="SYSTEM_ERR">/' api/src/main/resources/log4j2.xml
  sed -i 's/<Console name="console" target="SYSTEM_OUT">/<Console name="console" target="SYSTEM_ERR">/' lib/src/main/resources/log4j2.xml

  # Change volume calculation
#  sed -i 's/if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/volumeNorm = (float) Math.pow(volumeNorm, 3) \/ 2;\n        if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/' player/src/main/java/xyz/gianlu/librespot/player/mixing/AudioSink.java
  sed -i 's/if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/volumeNorm = (float) Math.pow(volumeNorm, 3);\n        if (output.setVolume(volumeNorm)) mixing.setGlobalGain(1);/' player/src/main/java/xyz/gianlu/librespot/player/mixing/AudioSink.java

  # Change cert trust. Bad, but necessary for now!
  #sed -i 's/OkHttpClient.Builder builder = new OkHttpClient.Builder();/TrustManager[] trustAllCerts = new TrustManager[]{\n            new X509TrustManager() {\n                @Override\n                public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) {\n                }\n\n                @Override\n                public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) {\n                }\n\n                @Override\n                public java.security.cert.X509Certificate[] getAcceptedIssuers() {\n                    return new java.security.cert.X509Certificate[]{};\n                }\n            }\n        };\n        SSLContext sslContext = SSLContext.getInstance("SSL");\n        sslContext.init(null, trustAllCerts, new java.security.SecureRandom());\n        OkHttpClient.Builder builder = new OkHttpClient.Builder();\n        builder.sslSocketFactory(sslContext.getSocketFactory(), (X509TrustManager) trustAllCerts[0]);\n        builder.hostnameVerifier((hostname, session) -> true);\n/' lib/src/main/java/xyz/gianlu/librespot/core/Session.java
  git apply allcerts.patch
  git diff

  mvn clean package
  cp ./player/target/librespot-player-${LIBRESPOT_JAVA_VERSION}*.jar /librespot-player.jar
fi
