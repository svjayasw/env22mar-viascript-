#!/bin/bash -ex

# This method came from this web site: http://www.linuxjournal.com/node/1005818

SELF_EXTRACT_FILE=selfextract.bsx

echo "this script is just an example. in real life, it's easy enough to incorporate into a Makefile"

PAYLOAD_TAR=payload.tar

cd payload
tar cf ../${PAYLOAD_TAR} ./*
cd ..

if [ ! -e "${PAYLOAD_TAR}" ]; then
    echo "Couldn't create ${PAYLOAD_TAR}"
    exit 1
fi

INFRA_BIN=$(dirname $0)
DOCS=${INFRA_BIN}/../release/docs
SCRIPTS=${INFRA_BIN}/../release/scripts

cat ${SCRIPTS}/decompress_src.sh ${DOCS}/EULA ${SCRIPTS}/payload-marker ${PAYLOAD_TAR} > $SELF_EXTRACT_FILE
chmod 755 $SELF_EXTRACT_FILE
rm -f ${PAYLOAD_TAR}

echo "$SELF_EXTRACT_FILE created"
exit 0
