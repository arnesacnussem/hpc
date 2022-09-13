FROM sacnussem/devcontainer:hpc-focal-quartus

COPY .bashrc /home/vscode/
RUN pip3 install teroshdl

COPY . /tmp
RUN bash /tmp/installStaticTool.sh