#!/bin/bash
# This script builds the iOS and Mac openSSL libraries
# Download openssl http://www.openssl.org/source/ and place the tarball next to this script
 
# Credits:
# https://github.com/st3fan/ios-openssl
# https://github.com/x2on/OpenSSL-for-iPhone/blob/master/build-libssl.sh
 
 
set -e
 
usage ()
{
	echo "usage: $0 [minimum iOS SDK version (default 7.0)]"
	exit 127
}
 
if [ $1 -e "-h" ]; then
	usage
fi
 
MIN_SDK_VERSION="7.0"
if [ -z $1 ]; then
	SDK_VERSION="12.1"
else
	SDK_VERSION=$1
fi
 
OPENSSL_VERSION="openssl-1.0.2p"
DEVELOPER=`xcode-select -print-path`
buildMac()
{
	ARCH=$1
	echo "Building ${OPENSSL_VERSION} for ${ARCH}"
	TARGET="darwin-i386-cc"
	if [[ $ARCH == "x86_64" ]]; then
		TARGET="darwin64-x86_64-cc"
	fi
	pushd . > /dev/null
	cd "${OPENSSL_VERSION}"
	./Configure ${TARGET} --openssldir="/tmp/${OPENSSL_VERSION}-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-${ARCH}.log"
	make >> "/tmp/${OPENSSL_VERSION}-${ARCH}.log" 2>&1
	make install >> "/tmp/${OPENSSL_VERSION}-${ARCH}.log" 2>&1
	make clean >> "/tmp/${OPENSSL_VERSION}-${ARCH}.log" 2>&1
	popd > /dev/null
}
buildIOS()
{
	ARCH=$1
	pushd . > /dev/null
	cd "${OPENSSL_VERSION}"
  
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
		PLATFORM="iPhoneSimulator"
	else
		PLATFORM="iPhoneOS"
		sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"
	fi
  
	export $PLATFORM
	export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export CROSS_SDK="${PLATFORM}${SDK_VERSION}.sdk"
	export BUILD_TOOLS="${DEVELOPER}"
	export CC="${BUILD_TOOLS}/usr/bin/gcc -arch ${ARCH}"
   
	echo "Building ${OPENSSL_VERSION} for ${PLATFORM} ${SDK_VERSION} ${ARCH}"
	if [[ "${ARCH}" == "x86_64" ]]; then
		./Configure darwin64-x86_64-cc --openssldir="/tmp/${OPENSSL_VERSION}-iOS-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-iOS-${ARCH}.log"
	else
		./Configure iphoneos-cross --openssldir="/tmp/${OPENSSL_VERSION}-iOS-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-iOS-${ARCH}.log"
	fi
	echo "Configure Done"
	# add -isysroot to CC=
	sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=${MIN_SDK_VERSION} -fembed-bitcode !" "Makefile"
	make >> "/tmp/${OPENSSL_VERSION}-iOS-${ARCH}.log" 2>&1
	make install_sw >> "/tmp/${OPENSSL_VERSION}-iOS-${ARCH}.log" 2>&1
	make clean >> "/tmp/${OPENSSL_VERSION}-iOS-${ARCH}.log" 2>&1
	popd > /dev/null
}
buildAndroid()
{
    # https://codeload.github.com/openssl/openssl/zip/OpenSSL_1_1_1c
    # https://github.com/openssl/openssl/archive/OpenSSL_1_1_1c.tar.gz
    # https://github.com/openssl/openssl/archive/OpenSSL_1_0_2h.tar.gz
    # openssl-1.0.2h
    # https://github.com/openssl/openssl/archive/OpenSSL_1_0_2h.zip

    ARCH=$1
    echo "Building ${OPENSSL_VERSION} for ${ARCH} on Android"
	pushd . > /dev/null
	cd "${OPENSSL_VERSION}"

    export ANDROID_NDK_HOME=/Users/yu.zuo/Library/Android/sdk/ndk-bundle
	export ANDROID_NDK_HOME_BY_GENERATE=/private/tmp/gcc/arm
	export PATH=$ANDROID_NDK_HOME_BY_GENERATE/bin:$PATH
	


    if [ "${ARCH}" == "arm" ]; then
		# ANDROID_EABI_PREFIX="arm-linux-androideabi"
		# ANDROID_EABI_PREFIX2="armv7a-linux-androideabi"
		# ANDROID_TOOLCHAIN=$ANDROID_NDK_HOME_BY_GENERATE
		# export AR=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-ar; echo AR=$AR
		# export AS=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-as; echo AS=$AS
		# export CC=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX2}21-clang; echo CC=$CC
		# export CXX=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX2}21-clang++; echo CXX=$CXX
		# export LD=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-ld; echo LD=$LD
		# export RANLIB=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-ranlib; echo RANLIB=$RANLIB
		# export STRIP=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-strip; echo STRIP=$STRIP
		read -n1 -p "Press any key to continue..."
        ./Configure android-armv7 -D__ANDROID_API__=21 --openssldir="/tmp/${OPENSSL_VERSION}-Android-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log"
    elif [ "${ARCH}" == "arm64" ]; then
		ANDROID_EABI_PREFIX=aarch64-linux-android
		ANDROID_TOOLCHAIN=$ANDROID_NDK_HOME_BY_GENERATE
		export AR=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-ar; echo AR=$AR
		export AS=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-as; echo AS=$AS
		export CC=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}21-clang; echo CC=$CC
		export CXX=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}21-clang++; echo CXX=$CXX
		export LD=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-ld; echo LD=$LD
		export RANLIB=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-ranlib; echo RANLIB=$RANLIB
		export STRIP=$ANDROID_TOOLCHAIN/bin/${ANDROID_EABI_PREFIX}-strip; echo STRIP=$STRIP
		read -n1 -p "Press any key to continue..."
        ./Configure android-arm64 --openssldir="/tmp/${OPENSSL_VERSION}-Android-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log"
	elif [ "${ARCH}" == "x86" ]; then
		./Configure android-arm64 --openssldir="/tmp/${OPENSSL_VERSION}-Android-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log"
	elif [ "${ARCH}" == "x86_64" ]; then
		./Configure android-arm64 --openssldir="/tmp/${OPENSSL_VERSION}-Android-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log"
    else
        ./Configure android64 --openssldir="/tmp/${OPENSSL_VERSION}-Android-${ARCH}" &> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log"
    fi

    make >> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
    make install_sw >> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
	make clean >> "/tmp/${OPENSSL_VERSION}-Android-${ARCH}.log" 2>&1
	popd > /dev/null
}
echo "Cleaning up"
rm -rf include/openssl/* lib/*
mkdir -p lib/iOS
mkdir -p lib/Mac
mkdir -p lib/Android
mkdir -p include/openssl/
rm -rf "/tmp/${OPENSSL_VERSION}-*"
rm -rf "/tmp/${OPENSSL_VERSION}-*.log"
rm -rf "${OPENSSL_VERSION}"
if [ ! -e ${OPENSSL_VERSION}.tar.gz ]; then
	echo "Downloading ${OPENSSL_VERSION}.tar.gz"
	curl -O https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz
else
	echo "Using ${OPENSSL_VERSION}.tar.gz"
fi
echo "Unpacking openssl"
tar xfz "${OPENSSL_VERSION}.tar.gz"

mv ./${OPENSSL_VERSION}/Configure ./${OPENSSL_VERSION}/Configure.bak
cp ./102pconfigurefile/Configure ./${OPENSSL_VERSION}/Configure

read -n1 -p "Press any key to continue..."
buildAndroid "arm"


# buildMac "i386"
# buildMac "x86_64"
# echo "Copying headers"
# cp /tmp/${OPENSSL_VERSION}-i386/include/openssl/* include/openssl/
# echo "Building Mac libraries"
# lipo \
# 	"/tmp/${OPENSSL_VERSION}-i386/lib/libcrypto.a" \
# 	"/tmp/${OPENSSL_VERSION}-x86_64/lib/libcrypto.a" \
# 	-create -output lib/Mac/libcrypto.a
# lipo \
# 	"/tmp/${OPENSSL_VERSION}-i386/lib/libssl.a" \
# 	"/tmp/${OPENSSL_VERSION}-x86_64/lib/libssl.a" \
# 	-create -output lib/Mac/libssl.a
# cp "/tmp/${OPENSSL_VERSION}-x86_64/lib/libcrypto.a" "lib/Mac/libcrypto.a"
# cp "/tmp/${OPENSSL_VERSION}-x86_64/lib/libssl.a" "lib/Mac/libssl.a"
# buildIOS "armv7"
# buildIOS "arm64"
# buildIOS "x86_64"
# buildIOS "i386"
# echo "Building iOS libraries"
# lipo \
# 	 "/tmp/${OPENSSL_VERSION}-iOS-armv7/lib/libcrypto.a" \
# 	 "/tmp/${OPENSSL_VERSION}-iOS-arm64/lib/libcrypto.a" \
# 	 "/tmp/${OPENSSL_VERSION}-iOS-x86_64/lib/libcrypto.a" \
# 	   -create -output lib/iOS/libcrypto.a
# lipo \
# 	"/tmp/${OPENSSL_VERSION}-iOS-armv7/lib/libssl.a" \
# 	"/tmp/${OPENSSL_VERSION}-iOS-arm64/lib/libssl.a" \
# 	"/tmp/${OPENSSL_VERSION}-iOS-x86_64/lib/libssl.a" \
# 	-create -output lib/iOS/libssl.a
# echo "Cleaning up"
# rm -rf /tmp/${OPENSSL_VERSION}-*
# rm -rf ${OPENSSL_VERSION}
echo "Done"
