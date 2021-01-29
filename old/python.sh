#!/bin/sh

#version=3.5.10
version=3.6.12
#version=3.7.9
#version=3.8.6
#version=3.9.0

wget https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz
tar xf Python-${version}.tar.xz
cd Python-${version}/
./configure --enable-optimizations
make -j 8
make install
