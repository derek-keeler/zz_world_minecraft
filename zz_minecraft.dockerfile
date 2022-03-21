FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu

# Override when the server binary is updated, if necessary
ARG MINECRAFT_SERVER_DOWNLOAD="https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar"
ARG WORLD_NAME="ZZWorld"
ARG ACCEPT_EULA=false

LABEL Author="Derek Keeler <34773432+derek-keeler@users.noreply.github.com>"

RUN apt-get -qq update && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y --no-install-recommends aptitude && \
    apt-get -qq install -y --no-install-recommends vim && \
    apt-get -qq install -y --no-install-recommends wget && \
    apt-get -qq install -y gnupg && \
    apt-get -qq install -y sudo && \
    groupadd minecraft && \
    useradd -g minecraft -G sudo -d /home/minecraft -m -s /bin/bash minecraft && \
    wget ${MINECRAFT_SERVER_DOWNLOAD} -O /home/minecraft/server.jar && \
    echo "#$(date)" > /home/minecraft/eula.txt && \
    echo "eula=${ACCEPT_EULA}" >> /home/minecraft/eula.txt 

ENV MC_WORLD_NAME=${WORLD_NAME}

# Run as our special non-root 'minecraft' user
USER minecraft

# Ports for minecraft server
EXPOSE 25255/tcp
EXPOSE 25565/udp

# ...be sure to run with `docker run -p <host-port>:<EXPOSE-port>`, one entry for each EXPOSEd port above

WORKDIR /home/minecraft

# Run this command:
ENTRYPOINT ["/bin/bash", "-c", "java -Xmx2048M -Xms2048M -jar server.jar --bonusChest --universe /minecraft --world /minecraft/${MC_WORLD_NAME} --nogui"]

