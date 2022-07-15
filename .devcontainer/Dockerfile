FROM sacnussem/devcontainer:hpc-focal

RUN apt-get update && apt-get install -y libgnat-9
RUN wget -qO- https://github.com/ghdl/ghdl/releases/download/nightly/ghdl-gha-ubuntu-20.04-gcc.tgz | tar zxvf - -C /usr
