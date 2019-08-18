#!/bin/bash
# ref: https://github.com/lllkey/android-openssl-build
# update by zuoyu

echo "############ compile-openssl-android.sh start... ############ "

set -e

CURRENT_DIR=$(cd `dirname $0`; pwd)
. $CURRENT_DIR/project_macro.sh

OPENSSL_VERSION="openssl-1.0.2p"

# _ANDROID_NDK_ROOT=$1
# _ANDROID_EABI=$2
# _ANDROID_ARCH=$3
# _ANDROID_API=$4
# _OPENSSL_ROOT=$5

# 需要配置的内容
# _ANDROID_NDK_ROOT="/Users/lsq/Desktop/work/android/adt-bundle-mac-x86_64-20140702/android-ndk-r8e"
# _OPENSSL_GCC_VERSION=4.7
# _ANDROID_API="android-14"
_ANDROID_NDK_ROOT="/Users/asterisk/Library/Android/sdk/ndk-bundle"
_OPENSSL_GCC_VERSION=4.9
_API=21
_OPENSSL_ROOT="${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}"
_INSTALL_ROOT="${PROJECT_TMP_DIR}/${OPENSSL_VERSION}" 
BUILD_SHARED=true
#BUILD_CLANG=true
# TARGET_ARCHITECTURES=( "armeabi-v7a" "arm64-v8a" "x86" "x86_64" )
TARGET_ARCHITECTURES=( "armeabi-v7a" )
# TARGET_ARCHITECTURES=( "arm64-v8a" )
#TARGET_ARCHITECTURES=( "x86_64" )
#TARGET_ARCHITECTURES=( "x86" )
#TARGET_ARCHITECTURES=( "mip_64" )
#TARGET_ARCHITECTURES=( "mip" )
_ANDROID_API="android-${_API}"

PLATFORM_LIBRARY_PREFIX="lib"
STATIC_LIBRARY_SUFFIX=".a"
SHARED_LIBRARY_SUFFIX=".so"
OPENSSL_MODULES=( "crypto" "ssl" )
NCPU=8
#NCPU=1

dir_is_exist2 ${_ANDROID_NDK_ROOT}


echo OPENSSL_VERSION=${OPENSSL_VERSION}
echo _ANDROID_NDK_ROOT=${_ANDROID_NDK_ROOT}
echo _OPENSSL_GCC_VERSION=${_OPENSSL_GCC_VERSION}
echo _API=${_API}
echo _OPENSSL_ROOT=${_OPENSSL_ROOT}
echo _INSTALL_ROOT=${_INSTALL_ROOT}
echo BUILD_SHARED=${BUILD_SHARED}
echo TARGET_ARCHITECTURES=${TARGET_ARCHITECTURES}
echo _ANDROID_API=${_ANDROID_API}
echo PLATFORM_LIBRARY_PREFIX=${PLATFORM_LIBRARY_PREFIX}
echo STATIC_LIBRARY_SUFFIX=${STATIC_LIBRARY_SUFFIX}
echo SHARED_LIBRARY_SUFFIX=${SHARED_LIBRARY_SUFFIX}
echo OPENSSL_MODULES=${OPENSSL_MODULES}
echo NCPU=${NCPU}
# read -n1 -p "Press any key to continue..."


echo "load Setenv-android-input.sh ..."
. $CURRENT_DIR/Setenv-android-input.sh
# read -n1 -p "Press any key to continue..."




echo "set openssl library name ..."
OPENSSL_LIBRARIES=()
for OPENSSL_MODULE in "${OPENSSL_MODULES[@]}"; do
    OPENSSL_LIBRARIES+=( "${PLATFORM_LIBRARY_PREFIX}${OPENSSL_MODULE}${STATIC_LIBRARY_SUFFIX}" )
    if [ "${BUILD_SHARED}" ]; then
        OPENSSL_LIBRARIES+=( "${PLATFORM_LIBRARY_PREFIX}${OPENSSL_MODULE}${SHARED_LIBRARY_SUFFIX}" )
    fi
done
echo OPENSSL_LIBRARIES=${OPENSSL_LIBRARIES}
# read -n1 -p "Press any key to continue..."


echo "clean up start..."
# echo ${PROJECT_OUTPUT_DIR}/lib/iOS
rm -rf ${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-*
rm -rf ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/Android
rm -rf ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/include
rm -rf ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}
mkdir -p ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/Android
mkdir -p ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/include/openssl/
echo "clean up done."
# read -n1 -p "Press any key to continue..."


download_and_unpack ${OPENSSL_VERSION}


echo "update Configure file .... on openssl-1.0.2p"
if [ "${OPENSSL_VERSION}" == "openssl-1.0.2p" ]; then
  echo "backup Configure file start..."
  mv ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}/Configure ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}/Configure.bak
  cp ${PROJECT_SHELLSCRIPT_DIR}/openssl-1.0.2p_Configure ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}/Configure
  echo "backup Configure file done."
fi
# read -n1 -p "Press any key to continue..."

echo "check gcc exit ?"
GCC_DIR=${PROJECT_OUTPUT_DIR}/gcc
dir_is_exist2 ${GCC_DIR}
# read -n1 -p "Press any key to continue..."


echo "build start..."
for TARGET_ARCHITECTURE in "${TARGET_ARCHITECTURES[@]}"; do

  if [ "$TARGET_ARCHITECTURE" == "armeabi-v7a" ]
  then
    ANDROID_EABI_PREFIX=arm-linux-androideabi
    _ANDROID_ARCH=arch-arm
    CONFIGURE_SWITCH="android-armv7"
    #CONFIGURE_SWITCH="android"
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
    #export ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -mfpu=neon"
    LOCAL_ANDROID_PREFIX=arm
  elif [ "$TARGET_ARCHITECTURE" == "arm64-v8a" ]
  then
    ANDROID_EABI_PREFIX=aarch64-linux-android
    _ANDROID_ARCH=arch-arm64
    CONFIGURE_SWITCH="android"
    ANDROID_DEV_INCLUDE_ROOT=aarch64-linux-android
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
    LOCAL_ANDROID_PREFIX=arm64
  elif [ "$TARGET_ARCHITECTURE" == "x86" ]
  then
    _ANDROID_ARCH=arch-x86
    CONFIGURE_SWITCH="android-x86"
    _ANDROID_EABI=x86-${_OPENSSL_GCC_VERSION}
    ANDROID_EABI_PREFIX=i686-linux-android
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
    LOCAL_ANDROID_PREFIX=x86
  elif [ "$TARGET_ARCHITECTURE" == "x86_64" ]
  then
    _ANDROID_ARCH=arch-x86_64
    #CONFIGURE_SWITCH="android-x86"
    CONFIGURE_SWITCH="android-x86_64"
    _ANDROID_EABI=x86_64-${_OPENSSL_GCC_VERSION}
    ANDROID_EABI_PREFIX=x86_64-linux-android
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
    LOCAL_ANDROID_PREFIX=x86_64
  elif [ "$TARGET_ARCHITECTURE" == "mip" ]
  then
    ANDROID_EABI_PREFIX=mipsel-linux-android
    _ANDROID_ARCH=arch-mips
    CONFIGURE_SWITCH="android-mips"
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  elif [ "$TARGET_ARCHITECTURE" == "mip_64" ]
  then
    ANDROID_EABI_PREFIX=mips64el-linux-android
    _ANDROID_ARCH=arch-mips64
    CONFIGURE_SWITCH="android-mips64"
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  else
      echo "Unsupported target ABI: $TARGET_ARCHITECTURE"
      exit 1
  fi
  ARCH=${LOCAL_ANDROID_PREFIX}
  echo ANDROID_EABI_PREFIX=${ANDROID_EABI_PREFIX}
  echo _ANDROID_ARCH=${_ANDROID_ARCH}
  echo CONFIGURE_SWITCH=${CONFIGURE_SWITCH}
  echo _ANDROID_EABI=${_ANDROID_EABI}
  echo ANDROID_DEV_INCLUDE_ROOT=${ANDROID_DEV_INCLUDE_ROOT}
  echo ANDROID_TOOLS=${ANDROID_TOOLS}
  echo ARCH=${ARCH}
  # read -n1 -p "Press any key to continue..."

  echo "check type ..."
  if [ -z "${LOCAL_ANDROID_PREFIX}" ]; then
    echo "xxx-gcc is not find."
    exit 1
  fi
  # read -n1 -p "Press any key to continue..."


  echo "update CFLAGS flags ..."
  export CFLAGS
  CFLAGS=" -D__ANDROID_API__=$_API "
  #CFLAGS="${ARCH_FLAGS} -arch ${TARGET_ARCHITECTURE} -D__ANDROID_API__=$_API"
  if [ "${BITCODE_ENABLED}" ]; then
      CFLAGS+= " -fembed-bitcode " 
  fi
  if [ ! "${BUILD_SHARED}" ]; then
      CFLAGS+= " -fvisibility=hidden " 
      CFLAGS+= " -fvisibility-inlines-hidden " 
  fi
  export CFLAGS=$CFLAGS
  echo "OpenSSL CFLAGS ${CFLAGS}"
  # read -n1 -p "Press any key to continue..."

  

  echo "update OPTIONS ..."
  OPTIONS=""
  if [ "${BUILD_SHARED}" ]; then
      OPTIONS+=" shared "
  fi
  if [ "$TARGET_ARCHITECTURE" == "x86_64" ]; then
      OPTIONS+=" no-asm "
  fi
  echo "OpenSSL OPTIONS ${OPTIONS}"
  # read -n1 -p "Press any key to continue..."


  echo "load Setenv-android-input.sh ..."
  say_hello ${_ANDROID_NDK_ROOT} ${_ANDROID_EABI} ${_ANDROID_ARCH} ${_ANDROID_API} 
  # read -n1 -p "Press any key to continue..."


  echo "add gcc dir to PATH ..."
  LOCAL_ANDROID_TOOLCHAIN="${PROJECT_OUTPUT_DIR}/gcc/${LOCAL_ANDROID_PREFIX}/bin"
  export PATH="${LOCAL_ANDROID_TOOLCHAIN}":"$PATH"
  echo "PATH=" $PATH
  # read -n1 -p "Press any key to continue..."


  echo "set android env ..."
  #export ANDROID_DEV_INCLUDE_ROOT=$ANDROID_DEV_INCLUDE_ROOT
  ANDROID_DEV_INCLUDE="${ANDROID_DEV}/include -I${ANDROID_NDK_ROOT}/sysroot/usr/include -I${ANDROID_NDK_ROOT}/sysroot/usr/include/${ANDROID_DEV_INCLUDE_ROOT}/"
  if [ "${BUILD_CLANG}" ]; then
    #ANDROID_DEV_INCLUDE+=" -I${ANDROID_NDK_ROOT}/sources/android/support/include --sysroot=${ANDROID_SYSROOT}"
    ANDROID_DEV_INCLUDE+=" --sysroot=${ANDROID_SYSROOT}"
  #popd || exit
  fi
  export ANDROID_DEV_INCLUDE=$ANDROID_DEV_INCLUDE
  export ANDROID_DEV_API="$_API"
  echo ANDROID_DEV_INCLUDE=${ANDROID_DEV_INCLUDE}
  echo ANDROID_DEV_API=${ANDROID_DEV_API}
  # read -n1 -p "Press any key to continue..."



  # pushd . > /dev/null
  # echo "configure start..."
  # echo ${OPTIONS[*]}
  # echo ${CONFIGURE_SWITCH}
  # cd ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}
  # ./Configure ${CONFIGURE_SWITCH} ${OPTIONS[*]} --openssldir="${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}" &> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log"
  # read -n1 -p "Press any key to continue..."
  # make >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
	# make install_sw >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
	# make clean >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
  # read -n1 -p "Press any key to continue..."
  # popd > /dev/null









  pushd . > /dev/null

  
  cd ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}
  echo "configure start..."
  CONFIGURE_COMMAND="./Configure ${CONFIGURE_SWITCH} ${OPTIONS[*]} --openssldir=${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}"
  # read -n1 -p "Press any key to continue..."
  echo "${CONFIGURE_COMMAND}" &> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log"
  eval "${CONFIGURE_COMMAND}" >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
  echo "configure done."
  echo "make start..."
  make depend >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
  make -j"${NCPU}" build_libcrypto build_libssl >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
  # make install_sw >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
  # make clean >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
  echo "make done."
  # read -n1 -p "Press any key to continue..."
  

  mkdir -p ${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}/lib
  mkdir -p ${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}/include
  for OPENSSL_LIBRARY in "${OPENSSL_LIBRARIES[@]}"; do
      OPENSSL_LIBRARY_PATH=$( find "${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}" -name "${OPENSSL_LIBRARY}" -print | head -n 1 )
      cp "${OPENSSL_LIBRARY_PATH}" "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}/lib"
  done
  # read -n1 -p "Press any key to continue..."

  echo "make clean start..."
  make clean >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
  echo "make clean done."
  # read -n1 -p "Press any key to continue..."

  popd > /dev/null
  
done
echo "build done."
# read -n1 -p "Press any key to continue..."

echo "recover Configure file .... on openssl-1.0.2p"
if [ "${OPENSSL_VERSION}" == "openssl-1.0.2p" ]; then
  echo "recover Configure file start..."
  rm -rf ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}/Configure
  mv ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}/Configure.bak ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}/Configure
  echo "recover Configure file done."
fi
# read -n1 -p "Press any key to continue..."











echo "############ compile-openssl-android.sh done. ############ "