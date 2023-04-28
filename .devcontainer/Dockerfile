FROM sacnussem/devcontainer:hpc-focal

COPY .bashrc /home/vscode/
RUN pip3 install teroshdl
RUN apt install -y jq graphviz

COPY . /