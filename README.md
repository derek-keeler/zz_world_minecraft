# ZZ World Minecraft Server Docker Container

A docker container definition that can be used to host your own Minecraft server.

This can be used on Docker for Windows, or docker on any OS you like, but the documentation
supplied here pertains to Docker on Windows running Linux containers.

The idea is to make it very simple to host your own service on your local network and
to be able to re-play the same world over and over.

## Prerequisites

Software and layout needs for this service:

- Ensure you have an adequate machine to run the server. See [server requirements on
minecraft.net](https://minecraft.fandom.com/wiki/Server/Requirements) for details. If
you are going to host _and_ play on the same computer, make sure your computer has the
minimum requirements for both server & client (the Minecraft download page has minimum
specs for the game).
- Install [Docker for Windows](https://docs.docker.com/desktop/windows/install/).
- Create a folder where all your Minecraft worlds will be stored. I use `C:\Minecraft`.

## Building the ZZ World Docker Image

1. Open a command window (cmd.exe or Powershell, on Windows).
1. `cd path/to/zz_minecraft.dockerfile`
1. Run docker build:

    ```bash
    docker build --build-arg ACCEPT_EULA=true \     # This is optional, but recommended.
                 --tag local/zz_minecraft:0.0.1
                 --file zz_minecraft.dockerfile .
    ```

1. Optionally, you can add the following:

    **Download URL**

    ```bash
    --build-arg MINECRAFT_SERVER_DOWNLOAD="https://launcher.mojang.com/v1/objects/blahblah/server.jar"
    ```

    Use this to specify an updated URL to the latest Minecraft server.
    First go to the website 'https://www.minecraft.net/en-us/download/server',
    and copy the URL to the latest server.jar file. It will be something like
    'https://launcher.mojang.com/v1/objects/blahblah/server.jar'. Default is
    the latest URL checked into the zz_minecraft dockerfile.

    **World Name**

    ```bash
    --build-arg WORLD_NAME="MyWonderfulWorldName"
    ```

    Use this to specify your world's name. The name will be used to name the
    folder that will contain the content for the world that is created. It's a
    good idea to avoid special characters and spaces (but not specifically
    necessary to do so). The default of `ZZWorld` will be used if you do not
    specify it here.

    **Accept EULA**

    ```bash
    --build-arg ACCEPT_EULA=true
    ```

    Issue this to mimic the startup behaviour of the server to tell you to accept
    the end user license agreement. If you do not specify this, you will have to
    edit the /home/minecraft/eula.txt file by using the `docker cp` command.

## Running the Container

Once built, to run this service, use (on Windows):

```bash
docker run -v C:\Minecraft\Universe:/minecraft --name mc_zzworld -p 25565:25565 -p 2222:22 zz_minecraft:0.0.1
```

This will store the universe files for Minecraft on the path `C:\Minecraft\Universe`,
and a folder underneath that will be constructed that holds the game files for your
world. (see WORLD_NAME above).

## Re-starting the Container

Once you've built and run this, you can now re-run it every time you wish to play without
having to build/create a new container.

Do so by issuing:

```bash
> docker start mc_zzworld
```

Now you can re-run the world whenever you want to play, and you can turn off
docker when you aren't playing.

> NOTE: **Overviewer** has a handy docker image all ready for us that you can use to get a nice
> map view of your world.
>
> Run it like so:
>
> ```bash
> docker run --name mc_over \
> --rm -e MINECRAFT_VERSION="<latest-version>" \ # you can obtain this from the Minecraft server download site...
> -v C:\Minecraft\${WORLD_NAME}:/home/minecraft/server/${WORLD_NAME}/:ro
> -v C:\Minecraft\Render:/home/minecraft/render:rw
> mide/minecraft-overviewer:latest
> ```
>
> Then open `C:\Minecraft\Render\index.html` in your browser to see your new  world!
>
> See [mide's](https://github.com/mide/minecraft-overviewer) GitHub site for more details.
