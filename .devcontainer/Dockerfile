FROM sacnussem/devcontainer:hpc-focal-quartus

COPY .bashrc /home/vscode/
RUN pip3 install teroshdl

COPY ./postCreateCommand.sh /
COPY ./postStartCommand.sh /