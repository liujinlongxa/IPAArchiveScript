#!/usr/bin/env bash

startbuild() {
    ipa build -w "${buildProjectDir}lazyaudio.xcworkspace" --clean -d ${buildDir} -s ${buildScheme} --ipa "${buildIpaName}.ipa" -c ${buildEnv} --verbose
    rm /Users/username/Desktop/*.ipa
    cp "${buildDir}/${buildIpaName}.ipa" /Users/username/Desktop
    echo '============== PACKAGE FINISH ============'
}

failed() {
    echo "$1"
    exit 1
}

# 指定编译版本目录名
echo -n '指定编译版本目录名(eg:226):'
read buildVersionDir
if [ -z ${buildVersionDir} ]
then
    failed 编译版本目录名不能为空
fi

# 指定编译版本
echo -n '指定编译版本(eg:v2.2.6):'
read buildVersion
if [ -z ${buildVersion} ]
then
    failed 编译版本不能为空
fi

# 指定编译环境目录名
echo -n '指定编译环境目录名(25/78/Release,默认25):'
read buildEnvDir
if [ -z ${buildEnvDir} ]
then
buildEnvDir=25
fi

# 指定编译环境
echo -n '请指定编译环境(Debug/Release,默认Debug):'
read buildEnv
if [ -z ${buildEnv} ]
then
    buildEnv=Debug
elif [ ${buildEnv} != 'Debug' -a ${buildEnv} != 'Release' ]
then
    failed 编译环境错误
fi

# 是否需要上传到ftp
echo -n '是否需要上传到ftp(Y/N,默认为Y):'
read uploadFTP
if [ -z ${uploadFTP} ]
then
    uploadFTP=y
fi

buildDay=$(date +"%Y%m%d_%H%M%S")
buildIpaName="appname_v${buildVersionDir}_e${buildEnvDir}_${buildDay}"
buildDir="/Users/username/Desktop/工作文档/打包/${buildVersion}/${buildEnvDir}/${buildIpaName}"
buildScheme=lazyaudio
buildProjectDir="/Users/username/Documents/Work/Code/lazy-client-ios/iphone2_0/"

if [ -e "${buildDir}/${buildIpaName}.ipa" ]
then
    failed 文件已存在，请重新设置build number
fi

echo "========== Build And Archive Path =========="
echo "${buildDir}/${buildIpaName}.ipa"
echo -n '是否确认继续(Y/N)'

read iscontinue

if [ "${iscontinue}" = "y" -o "${iscontinue}" = "Y" ]
then
    startbuild
else
    exit 0
fi

if [[ ! -e "${buildDir}/${buildIpaName}.ipa" ]]
then
    echo 打包失败
    exit 0
fi

ftpHost="192.168.2.123"
ftpIpaPath="/Users/username/Desktop/${buildIpaName}.ipa"
ftpIpaPath=${buildDir}
ftpUsername="iosteam"
ftpPassword="123456"
ftpPort="21"
ftpPath="/package/${buildVersion}/${buildEnvDir}/${buildIpaName}/"

if [ ${uploadFTP} = "y" -o ${uploadFTP} = "Y" ]
then
ftp -i -n -V <<!
open 192.168.2.123
user iosteam 123456
binary
hash
mkdir ${ftpPath}
cd ${ftpPath}
lcd ${ftpIpaPath}
prompt
mput *
close
bye
!
else
    exit 0
fi

echo "IPA路径: ${ftpIpaPath}"
echo "上传路径: ftp://192.168.2.123/IOSTeam${ftpPath}"
echo "END"
