#!/bin/bash

certsFile='IntelSHA2RootChain-Base64.zip'
certsUrl="http://certificates.intel.com/repository/certificates/$certsFile"
certsFolder='/usr/local/share/ca-certificates' #(Ubuntu)
cmd='/usr/sbin/update-ca-certificates' #(Ubuntu/Sles)
wget $certsUrl -O $certsFolder/$certsFile
unzip $certsFolder/$certsFile -d $certsFolder #(Ubuntu/SLES)
rm -f $certsFolder/$certsFile
chmod 644 $certsFolder/*.crt
eval "$cmd"
