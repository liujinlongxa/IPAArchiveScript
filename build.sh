#!/usr/bin/env bash

startbuild() {
    ipa build -w "${buildProjectDir}MyApp.xcworkspace" --clean -d ${buildDir} -s ${buildScheme} --ipa "iosApp_${buildIpaName}.ipa" -c ${buildEnv} --verbose
    rm /Users/liujinlong/Desktop/*.ipa
    cp "${buildDir}/iosApp_${buildIpaName}.ipa" /Users/liujinlong/Desktop
}

startuploadFTP() {
    ipa distribute:ftp --host ${ftpHost} -port ${ftpPort} -f ${ftpIpaPath} -u ${ftpUsername} -p ${ftpPassword} --path ${ftpPath} --mkdir
    echo '========= FTP UPLOAD PATH ============='
    echo "ftp://${ftpHost}${ftpPath}"
}

failed() {
    echo "$1"
    exit 1
}

# 指定编译版本
echo -n '指定编译版本(eg:v2.2.6):'
read buildVersion
if [ -z ${buildVersion} ]
then
    failed 编译版本不能为空
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

# 指定编译序号
echo -n '请输入build number:'
read buildNum
if [ -z ${buildNum} ]
then
    failed 编译序号不能为空
fi

# 是否需要上传到ftp
echo -n '是否需要上传到ftp(Y/N,默认为Y):'
read uploadFTP
if [ -z ${buildNum} ]
then
    uploadFTP=y
fi

buildDay=$(date +%m%d)
buildIpaName="${buildDay}_build${buildNum}"
buildDir="/Users/liujinlong/Desktop/${buildVersion}/${buildIpaName}"
buildScheme=MyApp
buildProjectDir="/Users/liujinlong/Documents/MyApp/"

if [ -e "${buildDir}/iosApp_${buildIpaName}.ipa" ]
then
    failed 文件已存在，请重新设置build number
fi

echo "========== Build And Archive Path =========="
echo "${buildDir}/iosApp_${buildIpaName}.ipa"
echo -n '是否确认继续(Y/N)'

read iscontinue

if [ ${iscontinue}=='y' -o ${iscontinue}=='Y' ]
then
    startbuild
fi

ftpHost="192.169.2.189"
ftpIpaPath="/Users/liujinlong/Desktop/iosApp_${buildIpaName}.ipa"
ftpUsername="127.0.0.1"
ftpPassword="123456"
ftpPort=8080
ftpPath="/IOSTeam/package/${buildIpaName}/"

if [ ${uploadFTP} == 'y' -o ${uploadFTP} == 'Y' ]
then
    startuploadFTP
fi

echo 'END'
