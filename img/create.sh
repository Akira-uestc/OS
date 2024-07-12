#!/bin/bash
qemu-img create -f qcow2 boot.img -o nocow=on 1M
