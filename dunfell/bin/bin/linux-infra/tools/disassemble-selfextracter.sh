#!/bin/bash -e

PKG=$1
DEST_DIR=$2
if [ -z "$DEST_DIR" ]; then
     echo "Usage: $(basename $0) <pkg.bsx> <directory to receive the guts>"
     exit 1
fi

echo "Disassembling package $PKG to $DEST_DIR"
if [ -d "${DEST_DIR}" ]; then
    echo "Directory exists (${DEST_DIR}).  Please clean up."
    exit 1
fi
if [ ! -e "$PKG" ]; then
    echo "Self-extracting pkg $PKG not found.  Giving up."
    exit 1
fi

mkdir -p ${DEST_DIR}/payload

# extract the eula.
sed -r -n '/^__EULA_BELOW__/,/^__ARCHIVE_BELOW__/p' $PKG | \
    egrep -v '__(EULA|ARCHIVE)_BELOW__' > ${DEST_DIR}/EULA

ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $PKG`
tail -n+$ARCHIVE $PKG | tar --no-same-owner -xv -C ${DEST_DIR}/payload
#tail -n+$ARCHIVE $PKG > ${DEST_DIR}/payload.tar

#find ${DEST_DIR} -type f

exit 0
