FROM sacnussem/devcontainer:hpc-focal

RUN wget --progress=bar:force:noscroll -O- https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2022-07-18/oss-cad-suite-linux-x64-20220718.tgz | tar zxf - -C /opt
RUN apt-get update && apt-get install -y libgnat-9 zlib1g-dev pip
RUN pip3 install teroshdl
COPY .bashrc /home/vscode/
# RUN wget -O- https://github.com/ghdl/ghdl/releases/download/nightly/ghdl-gha-ubuntu-20.04-gcc.tgz | tar zxf - -C /usr
