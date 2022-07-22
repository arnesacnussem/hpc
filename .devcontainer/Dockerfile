FROM sacnussem/devcontainer:hpc-focal

COPY .bashrc /home/vscode/
RUN apt-get update && apt-get install -y libgnat-9 zlib1g-dev pip libstdc++-10-dev clang tcl8.6-dev libreadline-dev 
RUN pip3 install teroshdl
RUN wget --progress=bar:force:noscroll -O- https://github.com/YosysHQ/oss-cad-suite-build/releases/download/`date +%Y-%m-%d --date="yesterday" -u`/oss-cad-suite-linux-x64-`date +%Y%m%d --date="yesterday" -u`.tgz | tar zxf - -C /opt
RUN wget --progress=bar:force:noscroll -O /tmp/teroshdl.vsix `curl -s https://api.github.com/repos/TerosTechnology/vscode-terosHDL/releases/latest | jq -r .assets[0].browser_download_url`
# RUN wget --progress=bar:force:noscroll -O- https://github.com/ghdl/ghdl/releases/download/nightly/ghdl-gha-ubuntu-20.04-llvm.tgz | tar zxf - -C /usr
