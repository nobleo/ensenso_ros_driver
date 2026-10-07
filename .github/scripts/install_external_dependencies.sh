#!/bin/bash

# Install script for external dependencies such as the Esenso SDK.

set -e

# Requires ENSENSO_INSTALL and ENSENSO_SDK_VERSION to be set.
sudo apt-get -y install dpkg wget
case "$(dpkg --print-architecture)" in
    amd64) ensenso_arch=x64 ;;
    arm64) ensenso_arch=arm64 ;;
    *) echo "Unsupported CPU architecture: $(dpkg --print-architecture)" >&2; exit 1 ;;
esac
wget -O /tmp/ensenso.deb "https://download.ensenso.com/s/ensensosdk/download?files=ensenso-sdk-${ENSENSO_SDK_VERSION}-${ensenso_arch}.deb"
# The arm64 .deb declares Depends on libgl1-mesa-glx, freeglut3 and libglib2.0-0, which no longer
# exist under those names on noble (libgl1-mesa-glx/freeglut3 were dropped, libglib2.0-0 was
# renamed to libglib2.0-0t64), so apt can never satisfy them by package name; ignore those three
# and install their modern equivalents explicitly (freeglut has no noble replacement).
sudo dpkg -i --ignore-depends=libgl1-mesa-glx,freeglut3,libglib2.0-0 /tmp/ensenso.deb
sudo apt-get install -f -y
sudo apt-get -y install libgl1 libglib2.0-0t64

if [[ $ROS_VERSION -eq "2" ]]; then
    sudo apt-get -y install libpcl-dev libopencv-dev python3-opencv
    sudo apt-get -y install ros-$ROS_DISTRO-tf-transformations
fi