
#!/bin/bash
# update by zuoyu on 2019.08.16
# ref: https://blog.csdn.net/jasonwang18/article/details/55510469



echo "############ generate_all_gcc.sh start... ############ "

set -e

# ./project_macro.sh
CURRENT_DIR=$(cd `dirname $0`; pwd)
. $CURRENT_DIR/project_macro.sh
# read -n1 -p "Press any key to continue..."

ANDROID_NDK_ROOT=/Users/asterisk/Library/Android/sdk/ndk-bundle
PLATFORM=android-21
SH_MAKE=$ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh
INSTALL_DIR=${PROJECT_OUTPUT_DIR}

echo check android ndk dir is exist?
dir_is_exist2 ${ANDROID_NDK_ROOT}

# init dirs
eval init



echo "ANDROID_NDK_ROOT=" $ANDROID_NDK_ROOT
echo "PLATFORM=" $PLATFORM
echo "SH_MAKE=" $SH_MAKE

rm -rf ${INSTALL_DIR}/gcc
 
archs=(
    'arm'
    'arm64'
    'x86'
    'x86_64'
    'mips'
    'mips64'
)
 
toolchains=(
    'arm-linux-androideabi-4.9'
    'aarch64-linux-android-4.9'
    'x86-4.9'
    'x86_64-4.9'
    'mipsel-linux-android-4.9'
    'mips64el-linux-android-4.9'
)
 


# read -n1 -p "Press any key to continue..."

num=${#archs[@]}
for ((i=0;i<$num;i++))
do
   sh $SH_MAKE --platform=$PLATFORM --force --install-dir=$INSTALL_DIR/gcc/${archs[i]} --toolchain=${toolchains[i]}
#    sh $SH_MAKE --arch=${archs[i]} --platform=$PLATFORM --force --install-dir=$INSTALL_DIR/gcc/${archs[i]} --toolchain=${toolchains[i]}
done


echo "############ generate_all_gcc.sh done. ############ "
