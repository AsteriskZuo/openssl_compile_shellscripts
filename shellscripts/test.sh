#!/bin/bash

if [ ! -f "/Users/yu.zuo/codes/_github/openssl_compile_shellscripts/shellscripts/Setenv-android-inputw.sh" ]; then
    echo "file is not find."
else
    echo "file is find."
fi


var1="ssss"
var2="ssss2"
# 判断两个变量是否相等
if [ "$var1" == "$var2" ]; then
  echo '$var1 eq $var2'
else
  echo '$var1 not eq $var2'
fi

# ./project_macro.sh
CURRENT_DIR=$(cd `dirname $0`; pwd)
. $CURRENT_DIR/project_macro.sh
# read -n1 -p "Press any key to continue..."

pwd
pushd . > /dev/null
cd ${PROJECT_OPENSSL_DIR}
pwd
popd > /dev/null
pwd

OPENSSL_MODULES=( "crypto" "ssl" )
echo "set openssl library name ..."
OPENSSL_LIBRARIES=()
for OPENSSL_MODULE in "${OPENSSL_MODULES[@]}"; do
    OPENSSL_LIBRARIES+=( "${PLATFORM_LIBRARY_PREFIX}${OPENSSL_MODULE}${STATIC_LIBRARY_SUFFIX}" )
    if [ "${BUILD_SHARED}" ]; then
        OPENSSL_LIBRARIES+=( "${PLATFORM_LIBRARY_PREFIX}${OPENSSL_MODULE}${SHARED_LIBRARY_SUFFIX}" )
    fi
done
echo OPENSSL_LIBRARIES=${OPENSSL_LIBRARIES}

# ARCH=arm
OPENSSL_VERSION="openssl-1.0.2p"
mkdir -p ${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}/lib
mkdir -p ${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}/include
  for OPENSSL_LIBRARY in "${OPENSSL_LIBRARIES[@]}"; do
      OPENSSL_LIBRARY_PATH=$( find "${PROJECT_OPENSSL_DIR}/${OPENSSL_VERSION}" -name "${OPENSSL_LIBRARY}" -print | head -n 1 )
      echo OPENSSL_LIBRARY_PATH=${OPENSSL_LIBRARY_PATH}
      cp "${OPENSSL_LIBRARY_PATH}" "${PROJECT_TMP_DIR}/${OPENSSL_VERSION}-Android-${ARCH}/lib"
  done
read -n1 -p "Press any key to continue..."


#shell判断文件夹是否存在

# #如果文件夹不存在，创建文件夹
# if [ ! -d "/myfolder" ]; then
#   mkdir /myfolder
# fi

# #shell判断文件,目录是否存在或者具有权限


# folder="/var/www/"
# file="/var/www/log"

# # -x 参数判断 $folder 是否存在并且是否具有可执行权限
# if [ ! -x "$folder"]; then
#   mkdir "$folder"
# fi

# # -d 参数判断 $folder 是否存在
# if [ ! -d "$folder"]; then
#   mkdir "$folder"
# fi

# # -f 参数判断 $file 是否存在
# if [ ! -f "$file" ]; then
#   touch "$file"
# fi

# # -n 判断一个变量是否有值
# if [ ! -n "$var" ]; then
#   echo "$var is empty"
#   exit 0
# fi

# 判断两个变量是否相等
# if [ "$var1" = "$var2" ]; then
#   echo '$var1 eq $var2'
# else
#   echo '$var1 not eq $var2'
# fi