#!/bin/bash -e

cd ~/repos/internal/uefi-socfpga

cmd='git push -f  portal origin/master:refs/heads/master'
echo $cmd
$cmd
