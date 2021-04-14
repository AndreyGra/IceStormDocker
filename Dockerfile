FROM ubuntu:20.04

ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update 
RUN apt install build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev \
                     qt5-default python3-dev libboost-all-dev cmake libeigen3-dev -y

WORKDIR /home/andrey/
RUN git clone https://github.com/YosysHQ/icestorm.git icestorm
WORKDIR /home/andrey/icestorm
RUN make -j$(nproc)
RUN make install

WORKDIR /home/andrey/
RUN git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
WORKDIR /home/andrey/arachne-pnr/
RUN make -j$(nproc)
RUN make install

WORKDIR /home/andrey/
RUN git clone --recurse-submodules https://github.com/YosysHQ/nextpnr.git
WORKDIR /home/andrey/nextpnr/
RUN cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
RUN make -j$(nproc)
RUN make install

WORKDIR /home/andrey/
RUN git clone https://github.com/YosysHQ/yosys.git yosys
WORKDIR /home/andrey/yosys/
RUN make -j$(nproc)
RUN make install

WORKDIR /etc/udev/rules.d/
RUN touch /etc/udev/rules.d/53-lattice-ftdi.rules
RUN echo 'ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0660", GROUP="plugdev", TAG+="uaccess" ' > /etc/udev/rules.d/53-lattice-ftdi.rules

RUN apt-get install verilator -y