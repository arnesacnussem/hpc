#!/bin/bash

BASEDIR=$(dirname "$0")

xpra start :100 --pulseaudio=no --bind-tcp=0.0.0.0:14500
