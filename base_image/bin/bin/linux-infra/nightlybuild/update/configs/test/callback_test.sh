# callbacks that implement build from GIT
# no OE, no recipe, plain build

CALLBACK_FILE=rt_callbacks

# varibales
export CROSS_COMPILE=/opt/altera-linux/linaro/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux/bin/arm-linux-gnueabihf-
export MACH=arm

function do_init() {

    echo "${FUNCNAME}: info: test test test"

    return 0

}

 
function do_build() {

    echo "${FUNCNAME}: info: test test test"

    return 0

}

function do_tag()  { 

    local tag=${1}

    
}
