#!/bin/bash
cd img
dd if=boot of=boot.img bs=512 count=1 conv=notrunc
