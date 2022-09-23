FROM sacnussem/devcontainer:hpc-focal-quartus

COPY .bashrc /home/vscode/
RUN pip3 install teroshdl
RUN apt install -y jq

COPY ./postCreateCommand.sh /
COPY ./postStartCommand.sh /