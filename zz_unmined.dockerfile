FROM mcr.microsoft.com/dotnet/runtime:8.0.11-bookworm-slim
# mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled-amd64 👈 if we want ubuntu 24

ARG UNMINED_CLI_DOWNLOAD="https://unmined.net/download/unmined-cli-linux-x64-dev/"

LABEL Author="Derek Keeler <34773432+derek-keeler@users.noreply.github.com>"

## Example CLI usage
#
# Render the web view of the "Zoe" world with a x3 zoom-in, show player locations, render 3d-object shadows,
# produce verbose log output, and force redrawing everything.
#
# .\unmined-cli.exe web render \
#       --world=E:\Minecraft\worlds\Zoe \
#       --output=E:\Minecraft\web\Zoe \
#       --players \
#       --zoomin 3 \
#       --shadows 3do \
#       --log-level verbose
#       --force

# Update the system packages, add an unpriviledged user, and download & unpack the unminer CLI
RUN apt-get -qq update && \
    apt-get -qq upgrade -y && \
    apt-get -qq install wget -y && \
    groupadd unminer && \
    useradd -g unminer -d /home/unminer -m -s /bin/bash unminer && \
    wget ${UNMINED_CLI_DOWNLOAD} -O /home/unminer/unmined-cli.tar.gz && \
    tar -xvzf /home/unminer/unmined-cli.tar.gz -C /home/unminer/ --transform 's!^[^/]*!unminer-cli!' && \
    mkdir /world /web

# Run as our special non-root 'minecraft' user
USER unminer

WORKDIR /home/unminer/unminer-cli

## INPUT files (Minecraft world files)
#
# The container expects two locations to be provded. The input folder is the folder that
# contains the Minecraft world we wish to render. Provide this on the `docker run` command
# line using the filesystem mounting parameters.
#
# Example:
# If our Minecraft data files are the 'default', they would be something like so:
# %APPDATA%\.minecraft\saves\My-Game
#
# If the "My-Game" world was the world you wanted to render, you would supply the INPUT folder
# like so in the docker run command:
#
# docker run <other_options> -v %APPDATA%\.minecraft\saves\My-Game:/world:ro <other_options> ...
#
## OUTPUT files (the web view built)
#
# The output folder is where you would like the created web pages to be stored after the app
# builds them for you. This could be something like "C:\Minecraft\web". Using this for an
# example, you specify the OUTPUT folder like so:
#
# docker run <other_options> -v C:\Minecraft\web:/web <other_options> ...

ENTRYPOINT [ "unminer-cli", \
    "web render", \
    "--world=/world", \
    "--output=/web", \
    "--players", \
    "--zoomin 3", \
    "--shadows 3do", \
    "--log-level verbose" ]
