#!/bin/bash
# This script create by zuoyu
# create date on 2019.08.16

echo "############ project_macro.sh start... ############ "

export PROJECT_ROOT=$(dirname $(pwd))
export PROJECT_SHELLSCRIPT_DIR=${PROJECT_ROOT}/shellscripts
export PROJECT_TMP_DIR=${PROJECT_ROOT}/tmp
export PROJECT_OUTPUT_DIR=${PROJECT_ROOT}/output 
export PROJECT_OPENSSL_DIR=${PROJECT_ROOT}/openssl 
export PROJECT_TEST_DIR=${PROJECT_ROOT}/testapp 

echo PROJECT_ROOT="${PROJECT_ROOT}"
echo PROJECT_SHELLSCRIPT_DIR="${PROJECT_SHELLSCRIPT_DIR}"
echo PROJECT_TMP_DIR="${PROJECT_TMP_DIR}"
echo PROJECT_OUTPUT_DIR="${PROJECT_OUTPUT_DIR}"
echo PROJECT_OPENSSL_DIR="${PROJECT_OPENSSL_DIR}"
echo PROJECT_TEST_DIR="${PROJECT_TEST_DIR}"

# read -n1 -p "Press any key to continue..."

str_is_empty() {
    CHECK_STR=$1
    if [ -z ${CHECK_STR} ]; then
        echo "str is empty."
        exit 1
    fi
}
create_dir() {
    CHECK_DIR=$1    
    if [ ! -d ${CHECK_DIR} ]; then
        echo "create ${CHECK_DIR} dir."
        mkdir -p ${CHECK_DIR}
    fi
}
dir_is_exist() {
    CHECK_DIR=$1    
    if [ ! -d ${CHECK_DIR} ]; then
        echo false
    else
        echo true
    fi
}
dir_is_exist2() {
    CHECK_DIR=$1    
    if [ ! -d ${CHECK_DIR} ]; then
        echo "${CHECK_DIR} is not exist."
        exit 1
    fi
}
init() {
    #创建目录
    str_is_empty ${PROJECT_TMP_DIR}
    create_dir ${PROJECT_TMP_DIR}
    str_is_empty ${PROJECT_OUTPUT_DIR}
    create_dir ${PROJECT_OUTPUT_DIR}
    str_is_empty ${PROJECT_OPENSSL_DIR}
    create_dir ${PROJECT_OPENSSL_DIR}
    # if [ ! -d ${PROJECT_TMP_DIR} ]; then
    #     echo "create ${PROJECT_TMP_DIR} dir"
    #     mkdir -p ${PROJECT_TMP_DIR}
    # fi
    # if [ ! -d ${PROJECT_OUTPUT_DIR} ]; then
    #     echo "create ${PROJECT_OUTPUT_DIR} dir"
    #     mkdir -p ${PROJECT_OUTPUT_DIR}
    # fi
    # if [ ! -d ${PROJECT_OPENSSL_DIR} ]; then
    #     echo "create ${PROJECT_OPENSSL_DIR} dir"
    #     mkdir -p ${PROJECT_OPENSSL_DIR}
    # fi
}
clean() {
    #如果SUB_DIR为空，则删除所有PROJECT_DIR文件夹目录下的文件    
    PROJECT_DIR=$1
    SUB_DIR=$2

    echo PROJECT_DIR=${PROJECT_DIR}
    echo SUB_DIR=${SUB_DIR}

    if [ -z "$PROJECT_DIR" ]; then
        echo "Error: PROJECT_DIR is not a valid path. Please edit this script."
        exit 1
    fi

    if [ -z "$SUB_DIR" ]; then
        rm -rf "$PROJECT_DIR"
    else
        rm -rf "$PROJECT_DIR/$SUB_DIR"
    fi

    # if [ -z "$SUB_DIR" ]; then
    #     cd $PROJECT_DIR
    #     rm -rf *
    #     cd ..
    # else
    #     cd $PROJECT_DIR
    #     cd $SUB_DIR
    #     rm -rf *
    #     cd ..
    #     cd ..
    # fi
}
clean_output() {
    SUB_DIR=$1
    clean ${PROJECT_OUTPUT_DIR} ${SUB_DIR}
}
clean_tmp() {
    SUB_DIR=$1
    clean ${PROJECT_TMP_DIR} ${SUB_DIR}
}
download_and_unpack() {
    OPENSSL_VERSION=$1
    echo "unpack start..."
    cd ${PROJECT_OPENSSL_DIR}
    if [ ! -e ${OPENSSL_VERSION}.tar.gz ]; then
        echo "Downloading ${OPENSSL_VERSION}.tar.gz"
        curl -O https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz
    else
        echo "Using ${OPENSSL_VERSION}.tar.gz"
    fi
    echo "Unpacking openssl"
    tar xfz "${OPENSSL_VERSION}.tar.gz"
    cd ${PROJECT_SHELLSCRIPT_DIR}
    echo "unpack done."
    # read -n1 -p "Press any key to continue..."
}

echo "############ project_macro.sh done. ############ "

############ test partition start ############ 
# echo "project_macro test start..."
# eval init
# TESTSS=""
# clean ${PROJECT_TMP_DIR} ${TESTSS}
# clean_tmp ${TESTSS}
# read -n1 -p "Press any key to continue..."
# echo "project_macro test done."
############ test partition end ############ 
