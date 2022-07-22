#!/bin/sh
FOLDER="/tmp/quartus_lite_21.1.0.842"
mkdir -p ${FOLDER}
wget --progress=bar:force:noscroll https://downloads.intel.com/akdlm/software/acdsinst/21.1std/842/ib_tar/Quartus-lite-21.1.0.842-linux.tar -O- | tar xf - -C ${FOLDER}
echo running installer with args: --mode unattended --unattendedmodeui minimal --accept_eula 1
sh ${FOLDER}/setup.sh --mode unattended --unattendedmodeui minimal --accept_eula 1
