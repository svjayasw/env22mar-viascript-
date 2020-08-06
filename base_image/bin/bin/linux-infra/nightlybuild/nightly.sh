export DATE=$(date +%Y-%m-%d)
cd ~/yocto/build-git/linux-infra/nightlybuild/
olddir="$(ls -1dt ~/yocto/nightly/* 2>/dev/null | tail -1)"
echo $olddir
if [ -d "$olddir" ]; then
        rm -rf $olddir
fi
export BUILD_DIR=~/yocto/nightly/$DATE
mkdir -p $BUILD_DIR
make BUILD_DIR=$BUILD_DIR 
