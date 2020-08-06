# THis file is the configuration to create the tags for the nightly builds
MACHINE="whatever"
RELEASE_NAME="$(date +'%F_%T' | sed 's/:/-/g')"
PACKAGING="git"
TAGS_REPO="gitolite@at-git:linux-tags"   # assume master branch
TAGS_FILE="linux-altera-tags"
TAGS_PREFIX="nbuild"
TAGS_SUFFIX="${RELEASE_NAME}"
LATEST_NAME="latest-nbuild-tags"

