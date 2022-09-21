#!/bin/bash

rm ~/.prj_config.teros || ln -s /workspaces/hpc/.prj_config.teros ~/.prj_config.teros
yarn
pip install -r requirement.txt
