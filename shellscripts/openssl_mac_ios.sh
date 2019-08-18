#!/bin/bash
# This script builds the iOS and Mac openSSL libraries
# Download openssl http://www.openssl.org/source/ and place the tarball next to this script
 
# Credits:
# https://github.com/st3fan/ios-openssl
# https://github.com/x2on/OpenSSL-for-iPhone/blob/master/build-libssl.sh
# https://blog.csdn.net/volvet/article/details/52183157
 
 
echo "############ openssl_mac_ios.sh start... ############ "

set -e

# ./project_macro.sh
CURRENT_DIR=$(cd `dirname $0`; pwd)
. $CURRENT_DIR/project_macro.sh
# read -n1 -p "Press any key to continue..."

eval init
 
usage ()
{
	echo "usage: $0 [minimum iOS SDK version (default 7.0)]"
	exit 127
}
 
if [ $1 -e "-h" ]; then
	usage
fi
 
MIN_SDK_VERSION="9.0" 
OPENSSL_VERSION="openssl-1.0.2p"
DEVELOPER=`xcode-select -print-path`
dir_is_exist2 "${DEVELOPER}"


buildMac()
{
	ARCH=$1
	
	TARGET="darwin-i386-cc"
	if [[ $ARCH == "x86_64" ]]; then
		TARGET="darwin64-x86_64-cc"
	fi

	pushd . > /dev/null

	echo "Building ${OPENSSL_VERSION} for Mac ${TARGET} ${ARCH}"
	# echo ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}
	cd "${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}"

	./Configure ${TARGET} --openssldir="${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-${ARCH}" &> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-${ARCH}.log"
	make >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-${ARCH}.log" 2>&1
	make install >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-${ARCH}.log" 2>&1
	make clean >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-${ARCH}.log" 2>&1
	
	popd > /dev/null
}
buildIOS()
{
	ARCH=$1
	pushd . > /dev/null
	cd "${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}"
  
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
		PLATFORM="iPhoneSimulator"
		IOS_TYPE="iphonesimulator"
	else
		PLATFORM="iPhoneOS"
		IOS_TYPE="iphoneos"
		sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"
	fi
  
	# xcodebuild -showsdks
	SDK_VERSION=`xcodebuild -sdk ${IOS_TYPE} -version | grep 'SDKVersion' | cut -d' ' -f2`
	export PLATFORM
	export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export CROSS_SDK="${PLATFORM}${SDK_VERSION}.sdk"
	export BUILD_TOOLS="${DEVELOPER}"
	export CC="${BUILD_TOOLS}/usr/bin/gcc -arch ${ARCH}"

	echo PLATFORM=${PLATFORM}
	echo CROSS_TOP=${CROSS_TOP}
	echo CROSS_SDK=${CROSS_SDK}
	echo CC=${CC}
	echo ${CROSS_TOP}/SDKs/${CROSS_SDK}
	dir_is_exist2 ${CROSS_TOP}/SDKs/${CROSS_SDK}
	# read -n1 -p "Press any key to continue..."
   
	echo "Building ${OPENSSL_VERSION} for ${PLATFORM} ${SDK_VERSION} ${ARCH}"
	# echo ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}	

	if [[ "${ARCH}" == "x86_64" ]]; then
		./Configure darwin64-x86_64-cc --openssldir="${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-${ARCH}" &> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-${ARCH}.log"
	else
		./Configure iphoneos-cross --openssldir="${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-${ARCH}" &> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-${ARCH}.log"
	fi
	# echo "Configure Done"
	# add -isysroot to CC=
	sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=${MIN_SDK_VERSION} -fembed-bitcode !" "Makefile"
	make >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-${ARCH}.log" 2>&1
	make install_sw >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-${ARCH}.log" 2>&1
	make clean >> "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-${ARCH}.log" 2>&1

	popd > /dev/null
}




echo "clean up start..."
# echo ${PROJECT_OUTPUT_DIR}/lib/iOS
rm -rf ${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-*
rm -rf ${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-*
rm -rf ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/iOS
rm -rf ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/Mac
rm -rf ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/include
rm -rf ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}
mkdir -p ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/iOS
mkdir -p ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/Mac
mkdir -p ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/include/openssl/
echo "clean up done."
# read -n1 -p "Press any key to continue..."

download_and_unpack ${OPENSSL_VERSION}
# echo "unpack start..."
# cd ${PROJECT_OPENSSL_DIR}
# if [ ! -e ${OPENSSL_VERSION}.tar.gz ]; then
# 	echo "Downloading ${OPENSSL_VERSION}.tar.gz"
# 	curl -O https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz
# else
# 	echo "Using ${OPENSSL_VERSION}.tar.gz"
# fi
# echo "Unpacking openssl"
# tar xfz "${OPENSSL_VERSION}.tar.gz"
# cd ${PROJECT_SHELLSCRIPT_DIR}
# echo "unpack done."
# # read -n1 -p "Press any key to continue..."

echo "build start..."

# buildMac "i386"
buildMac "x86_64"
echo "lipo Mac start..."
# lipo \
# 	"${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-i386/lib/libcrypto.a" \
# 	"${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-x86_64/lib/libcrypto.a" \
# 	-create -output lib/Mac/libcrypto.a
# lipo \
# 	"${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-i386/lib/libssl.a" \
# 	"${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-x86_64/lib/libssl.a" \
# 	-create -output lib/Mac/libssl.a
cp "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-x86_64/lib/libcrypto.a" "${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/Mac/libcrypto.a"
cp "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Mac-x86_64/lib/libssl.a" "${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/Mac/libssl.a"
echo "lipo Mac done."

buildIOS "armv7"
buildIOS "arm64"
buildIOS "x86_64"
# buildIOS "i386"
echo "lipo iOS start..."
lipo \
	 "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-armv7/lib/libcrypto.a" \
	 "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-arm64/lib/libcrypto.a" \
	 "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-x86_64/lib/libcrypto.a" \
	   -create -output ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/iOS/libcrypto.a
lipo \
	"${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-armv7/lib/libssl.a" \
	"${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-arm64/lib/libssl.a" \
	"${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-iOS-x86_64/lib/libssl.a" \
	-create -output ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/lib/iOS/libssl.a
echo "lipo iOS end."

echo "copy ssl header start..."
cp -p ${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}/include/openssl/* ${PROJECT_OUTPUT_DIR}/${OPENSSL_VERSION}/include/openssl
echo "copy ssl header done."

echo "build done."
# read -n1 -p "Press any key to continue..."

echo "############ openssl_mac_ios.sh done. ############ "
