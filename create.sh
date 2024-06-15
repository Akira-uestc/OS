#!/bin/bash
qemu-img create -f qcow2 image_file -o nocow=on 1M
