FROM mcr.microsoft.com/openjdk/jdk:21-ubuntu

# Override when the server binary is updated, if necessary
# See: https://www.minecraft.net/en-us/download/server
ARG MINECRAFT_SERVER_DOWNLOAD="https://piston-data.mojang.com/v1/objects/05e4b48fbc01f0385adb74bcff9751d34552486c/server.jar"
ARG MINECRAFT_SERVER_VERSION="1.21.7"
ARG WORLD_NAME="ZZWorld"
ARG ACCEPT_EULA=false
ARG MC_USER_UID=1000

LABEL Author="Derek Keeler <34773432+derek-keeler@users.noreply.github.com>"

RUN apt-get -qq update && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y --no-install-recommends aptitude && \
    apt-get -qq install -y --no-install-recommends vim && \
    apt-get -qq install -y --no-install-recommends wget && \
    apt-get -qq install -y gnupg && \
    apt-get -qq install -y sudo && \
    apt-get autoremove -y -q && \
    apt-get clean -y -q && \
    groupadd minecraft && \
    useradd -g minecraft -G sudo -d /home/minecraft -m -s /bin/bash minecraft -u ${MC_USER_UID} && \
    wget ${MINECRAFT_SERVER_DOWNLOAD} -O /home/minecraft/server.jar && \
    echo "#$(date)" > /home/minecraft/eula.txt && \
    echo "eula=${ACCEPT_EULA}" >> /home/minecraft/eula.txt 

ENV MC_WORLD_NAME=${WORLD_NAME}
ENV MC_VERSION=${MINECRAFT_SERVER_VERSION}

# Run as our special non-root 'minecraft' user
USER minecraft

# Ports for minecraft server
EXPOSE 25255/tcp
EXPOSE 25565/udp

# ...be sure to run with `docker run -p <host-port>:<EXPOSE-port>`, one entry for each EXPOSEd port above

WORKDIR /home/minecraft

# Run this command:
ENTRYPOINT ["/bin/bash", "-c", "java -Xmx2048M -Xms2048M -jar server.jar --bonusChest --universe /minecraft --world /minecraft/${MC_WORLD_NAME} --nogui"]
