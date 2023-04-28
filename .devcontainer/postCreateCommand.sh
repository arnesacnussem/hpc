#!/bin/bash

rm ~/.prj_config.teros || ln -s /workspaces/hpc/.prj_config.teros ~/.prj_config.teros
yarn install
pip install -r requirement.txt
sudo tailscale up --accept-routes --authkey "$TSKEY_AUTH"