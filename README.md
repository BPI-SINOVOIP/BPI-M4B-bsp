## **BPI-M4B-bsp**
Banana Pi M4Berry and M4Zero board bsp (u-boot 2018.05 & Kernel 5.4.125)

----------
**Prepare**

[Install Docker Engine](https://docs.docker.com/engine/install/) on your platform.

Get the docker image from [Sinovoip Docker Hub](https://hub.docker.com/r/sinovoip/bpi-build-linux-4.4/) , Build the source code with this docker environment.

Download source code

    $ git clone https://github.com/BPI-SINOVOIP/BPI-M4B-bsp
    $ cd BPI-M4B-bsp
    $ git submodule update --init --recursive

 **Build**

Build all bsp packages, please run

    # ./build.sh bpi-m4berry 1        //build m4berry bsp
    # ./build.sh bpi-m4zero 1         //build m4zero bsp

Target download packages in SD/bpi-xxx after build. Please check the build.sh and Makefile for detail

**Install**

Get the board image from [bpi](http://wiki.banana-pi.org/) and download it to the SD card. After finish, insert the SD card to PC

    # ./build.sh bpi-m4berry 6        //install m4berry bsp
    # ./build.sh bpi-m4zero 6         //install m4zero bsp

Choose the type, enter the SD dev, and confirm yes, all the build packages will be installed to target SD card.
