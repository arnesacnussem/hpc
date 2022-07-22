#!/bin/sh
find ./vhdl/gen -type f -name *.vhdl -print0 | xargs -0
find ./vhdl/src -type f -name *.vhdl -print0 | xargs -0
find ./vhdl/test -type f -name *.vhdl -print0 | xargs -0