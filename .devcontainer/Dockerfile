FROM sacnussem/devcontainer:hpc-focal-quartus

COPY .bashrc /home/vscode/
RUN apt-get update && apt-get install -y libgnat-9 zlib1g-dev
RUN pip3 install teroshdl
RUN wget -q --show-progress --progress=bar:force:noscroll -O- https://github.com/YosysHQ/oss-cad-suite-build/releases/download/$(date +%Y-%m-%d --date="yesterday" -u)/oss-cad-suite-linux-x64-$(date +%Y%m%d --date="yesterday" -u).tgz | tar zxf - -C /opt
ENV PATH=/opt/oss-cad-suite/bin:$PATH
# RUN wget --progress=bar:force:noscroll -O- https://github.com/ghdl/ghdl/releases/download/nightly/ghdl-gha-ubuntu-20.04-llvm.tgz | tar zxf - -C /usr
