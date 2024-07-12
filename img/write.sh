#!/bin/bash
dd if=mbr.bin of=boot.img bs=512 count=1 conv=notrunc
