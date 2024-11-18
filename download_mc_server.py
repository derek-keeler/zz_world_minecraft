#!/usr/bin/python3

# NOTE: Originally taken from `mide` from his extremely helpful
# minecraft-overviewer docker image project.
#
# https://github.com/mide/minecraft-overviewer (MIT license)
#

# flake8: noqa: F821,F401,E501
import argparse
import hashlib
import json
import os
import urllib.request

VERSION = "1.0.0"


def get_json_from_url(url):
    if not url.startswith("https://"):
        raise RuntimeError(f"Expected URL to start with https://. It was '{url}'.")
    request = urllib.request.Request(url)
    response = urllib.request.urlopen(request)
    return json.loads(response.read().decode())


def get_minecraft_download_url(mc_version: str, manifest_url: str):
    data = get_json_from_url(manifest_url)
    get_version = data["latest"]["release"]
    if mc_version != "latest":
        get_version = mc_version

    desired_versions = list(filter(lambda v: v["id"] == get_version, data["versions"]))
    if len(desired_versions) == 0:
        raise RuntimeError(
            f"Couldn't find Minecraft Version {mc_version}"
            f"in manifest file {manifest_url}."
        )
    elif len(desired_versions) > 1:
        raise RuntimeError(
            f"Found more than one record published for version {mc_version} "
            f"in manifest file {manifest_url}."
        )

    version_manifest_url = desired_versions[0]["url"]
    data = get_json_from_url(version_manifest_url)

    download_url = data["downloads"]["server"]["url"]
    download_sha = data["downloads"]["server"]["sha1"]
    return download_url, download_sha


def build_arguments() -> None:
    """Build command-line arguments for the script."""

    parser = argparse.ArgumentParser(
        description="Determine the latest Minecraft Server jar to download.",
        allow_abbrev=True,
    )

    parser.add_argument(
        "--version",
        "-v",
        help="Print version and exit.",
        action="version",
        version=f"%(prog)s {VERSION}",
    )
    parser.add_argument(
        "--minecraft-version",
        "-m",
        help="Minecraft server jar version to download. Default='latest'.",
        default="latest",
        type=str,
    )
    parser.add_argument(
        "--manifest-url",
        "-u",
        help="URL of Minecraft server jar file. Default='launchermeta.mojang.com/...'.",
        default="https://launchermeta.mojang.com/mc/game/version_manifest.json",
        type=str,
    )
    parser.add_argument(
        "--download",
        "-d",
        help="Download the Minecraft server jar file. Default=False.",
        action="store_true",
    )
    return parser.parse_args()


def do_download(mc_url: str, mc_sha1: str) -> None:
    """Download the Minecraft server jar file."""
    print(f"Downloading {mc_url}...")
    urllib.request.urlretrieve(mc_url, "server.jar")
    print("Done.")

    print("Verifying SHA1 checksum...")
    with open("server.jar", "rb") as f:
        data = f.read()
        sha1 = hashlib.sha1(data).hexdigest()
        if sha1 != mc_sha1:
            raise RuntimeError(
                f"SHA1 checksum does not match. Expected '{mc_sha1}', "
                f"but got '{sha1}'."
            )
    print("Done.")


if __name__ == "__main__":
    args = build_arguments()

    url, sha1 = get_minecraft_download_url(
        mc_version=args.minecraft_version, manifest_url=args.manifest_url
    )

    # Print out URL for consumption by another program.
    print(f"Download URL: {url}")
    print(f"SHA1: {sha1}")

    if args.download:
        do_download(url, sha1)
