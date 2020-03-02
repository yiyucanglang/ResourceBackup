#bin/bash - 1
export LANG=en_US.UTF-8
export LANGUAGE=en.US.UTF-8
export LC_ALL=en_US.UTF-8

PROJECT_DIR=$WORKSPACE/SRC
cd ${PROJECT_DIR}

BUILD_CONFIGURATION="Release"
EXPORT_CONFIGURATION=${EXPORT_SET}


#默认是workspace的
PROJECT_NAME=ZMBrainTrainPad
PROJECT_SCHEME=${BUILD_SCHEME}
BUILD_CONFIGURATION=${BUILD_CONFIGURATION}
#默认打的包是测服的包
EXPORTOPTION_PATH=../ExportPlists/Development_ExportOptions.plist
LASTESTTWOCOMMITLOG=""


echo "EXPORTOPTION_PATH:${EXPORTOPTION_PATH}"
echo ${PROJECT_DIR}

WORKSPACE_FILE=${PROJECT_NAME}.xcworkspace

echo "移除并创建新的打包输出相关文件夹"

EXPORTBASEDIR=${BUILD_CONFIGURATION}

ARCHIVE_DIR=/${WORKSPACE}/output/${EXPORTBASEDIR}/build_archive
EXPORT_DIR=/${WORKSPACE}/output/${EXPORTBASEDIR}
DSYM_DIR=/${WORKSPACE}/output/${EXPORTBASEDIR}/build_dsym

rm -rf /${WORKSPACE}/output/${EXPORTBASEDIR}

mkdir -p ${ARCHIVE_DIR}
mkdir -p ${EXPORT_DIR}
mkdir -p ${DSYM_DIR}

LOGPATH=/${WORKSPACE}/output/${EXPORTBASEDIR}/log.txt
#通知到钉钉的Json文件(一个ipa对应一个dingdingNotificationJson)
touch ${LOGPATH}

ARCHIVE_PATH=${ARCHIVE_DIR}/${PROJECT_SCHEME}.xcarchive

# #选择打包的xcode
# sudo xcode-select -s ~/Desktop/Xcode.app/Contents/Developer
# xcode-select -p
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p


echo "打包之前先清理工程"
# 编译前清理工程
xcodebuild clean -workspace ${WORKSPACE_FILE} \
-scheme ${PROJECT_SCHEME} \

echo "清理完成"

echo "开始编译打包成Archive"
BEGIIN_TIME=`date +%s`

security unlock-keychain -p '123456' ~/Library/Keychains/login.keychain-db

xcodebuild archive -workspace ${PROJECT_NAME}.xcworkspace \
-scheme ${PROJECT_SCHEME} \
-archivePath ${ARCHIVE_PATH} \
-quiet


echo "~~~~~~~~~~~~~~~~~~~~~~~~ 查看是否版本构建成功 ~~~~~~~~~~~~~~~~~~~~~~~~"
#xcrachive 是一个文件夹不是个文件 所以使用 -d 来判断
if [ -d $ARCHIVE_PATH ]
then
    echo "版本构建成功!"
    APPDSYM=${ARCHIVE_PATH}/dSYMs/${PROJECT_NAME}.app.DSYM
    if [ -d ${APPDSYM} ];
    then
        cp -rf ${APPDSYM} ${DSYM_DIR}/
        echo "DSYM文件导出成功!"
    fi
else
    echo "版本构建失败......"
    exit 1
fi

END_TIME=`date +%s`
ARCHIVE_TIME="构建版本所耗时间$[ END_TIME - BEGIIN_TIME ]秒"
echo "${CFBundleShortVersionString}"
BEGIIN_TIME=`date +%s`
echo "开始导出ipa包"

xcodebuild  -exportArchive \
-archivePath ${ARCHIVE_PATH} \
-exportOptionsPlist ${EXPORTOPTION_PATH} \
-exportPath ${EXPORT_DIR}



export EXPORT_IPA=${EXPORT_DIR}/${PROJECT_SCHEME}.ipa
export EXPORT_APPS=${EXPORT_DIR}/Apps/${PROJECT_SCHEME}.ipa

#如果是文件则说明成功
if [ -f ${EXPORT_IPA} ]
then
    echo "导出ipa成功! 🎉  🎉  🎉 "
    open ${EXPORT_DIR}
else
    if [ -f ${EXPORT_APPS} ]
    then
        echo "导出ipa成功! 🎉  🎉  🎉 "
        open ${EXPORT_DIR} 
    else
        echo "ipa导出失败......😢 😢 😢 "
        exit 1
    fi
fi

END_TIME=`date +%s`
EXPORT_IPA_TIME="导出ipa所耗时间$[ END_TIME - BEGIIN_TIME ]秒"

echo "时间消耗"
echo "$ARCHIVE_TIME"
echo "$EXPORT_IPA_TIME"
echo "你好牛逼啊！！！！！！"

sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p

