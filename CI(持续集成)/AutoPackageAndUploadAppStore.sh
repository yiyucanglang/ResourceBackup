#bin/bash - 1
export LANG=en_US.UTF-8

export LANGUAGE=en.US.UTF-8

export LC_ALL=en_US.UTF-8


cd $WORKSPACE


RN_ShengXue=../RN_ShengXue
ZMTeacherCommunity=../ZMTeacherCommunity
ShengXueOnline=../SXAppUploadAppStore

if [ -d ${RN_ShengXue} ];then

	if [ "`ls -A ${RN_ShengXue}`" = "" ]; then
  		echo "${RN_ShengXue} is  empty"
        git clone -b develop git@zmgitlab1.zmlearn.com:xiaoyong.chen/RN_ShengXue.git ${RN_ShengXue}
	else
  		echo "${RN_ShengXue} is not empty"
        cd ${RN_ShengXue}
        git pull origin develop
    fi
    
else
	git clone -b develop git@zmgitlab1.zmlearn.com:xiaoyong.chen/RN_ShengXue.git ${RN_ShengXue}
fi


cd $WORKSPACE
if [ -d ${ZMTeacherCommunity} ];then

	if [ "`ls -A ${ZMTeacherCommunity}`" = "" ]; then
  		echo "${ZMTeacherCommunity} is  empty"
        git clone -b feature/ShengXue_FromZMParentTag git@zmgitlab1.zmlearn.com:ios/ZMTeacherCommunity.git ${ZMTeacherCommunity}
	else
  		echo "${ZMTeacherCommunity} is not empty"
        cd ${ZMTeacherCommunity}
        git pull origin feature/ShengXue_FromZMParentTag
    fi
    
else
	git clone -b feature/ShengXue_FromZMParentTag git@zmgitlab1.zmlearn.com:ios/ZMTeacherCommunity.git ${ZMTeacherCommunity}
fi



PROJECT_DIR=${ShengXueOnline}
cd ${ShengXueOnline}
echo "当前路径:"
pwd


PROJECT_NAME=ShengXue
PROJECT_SCHEME=ShengXue
BUILD_CONFIGURATION=Release
EXPORTOPTION_PATH=${PROJECT_DIR}/AutoPackage/SXAPPSTOREExportOptions.plist
WORKSPACE_FILE=${PROJECT_NAME}.xcworkspace


INFOPLIST_PATH=${PROJECT_DIR}/${PROJECT_NAME}/info.plist

#获取版本号
CURRENT_BUILD_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${INFOPLIST_PATH})

echo "当前版本号:${CURRENT_BUILD_VERSION}"
 
#版本号+1
VERSION_ARR=(${CURRENT_BUILD_VERSION//./ })

ARR_NUM=${#VERSION_ARR[@]}

NEW_BUILD_VERSION=""
for ((i=0;i<${ARR_NUM};i++)) {

VAL=${VERSION_ARR[i]}

if [ $i == "`expr ${ARR_NUM} - 1`" ]; then

VAL=`expr ${VERSION_ARR[i]} + 1`

fi


if [ -z "${NEW_BUILD_VERSION}" ]; then

NEW_BUILD_VERSION=${VAL}

else
NEW_BUILD_VERSION=${NEW_BUILD_VERSION}"."${VAL}
fi

}

echo "设置版本号${NEW_BUILD_VERSION}"

#修改Version版本号
/usr/libexec/PlistBuddy -c "Set CFBundleVersion ${NEW_BUILD_VERSION}" ${INFOPLIST_PATH}


echo "移除并创建新的打包输出相关文件夹"

BUILDTIME=`date +%Y-%m-%d_%H:%M:%S`
EXPORTBASEDIR=${PROJECT_NAME}_Release_${BUILDTIME}

ARCHIVE_DIR=~/Desktop/${EXPORTBASEDIR}/build_archive
EXPORT_DIR=~/Desktop/${EXPORTBASEDIR}/build_ipa
DSYM_DIR=~/Desktop/${EXPORTBASEDIR}/build_dsym

rm -rf ~/Desktop/${EXPORTBASEDIR}


mkdir -p ${ARCHIVE_DIR}
mkdir -p ${EXPORT_DIR}
mkdir -p ${DSYM_DIR}

LOGPATH=~/Desktop/${EXPORTBASEDIR}/log.txt

touch ${LOGPATH}

echo "打包之前先清理"

xcodebuild clean -configuration ${BUILD_CONFIGURATION} -scheme ${PROJECT_SCHEME} -quiet >> ${LOGPATH}

echo "清理完成"

echo "更新cocoapods库"

/usr/local/bin/pod install


echo "开始编译打包成Archive"

BEGIIN_TIME=`date +%s`
  
CONFIGURATION_BUILD_PATH=${CONFIGURATION_BUILD_DIR}/${BUILD_CONFIGURATION}-iphoneos

ARCHIVE_PATH=${ARCHIVE_DIR}/${PROJECT_SCHEME}.xcarchive 


xcodebuild archive -workspace ${WORKSPACE_FILE} -scheme ${PROJECT_SCHEME} -configuration ${BUILD_CONFIGURATION} -archivePath ${ARCHIVE_PATH} -quiet >> ${LOGPATH}

echo "~~~~~~~~~~~~~~~~~~~~~~~~ 查看是否版本构建成功 ~~~~~~~~~~~~~~~~~~~~~~~~"
 
#xcrachive 是一个文件夹不是个文件 所以使用 -d 来判断  
   
if [ -d $ARCHIVE_PATH ]  
    then  
        echo "版本构建成功!"
        
        APPDSYM=${ARCHIVE_PATH}/dSYMs/${PROJECT_NAME}.app.DSYM
        
        if [ -d ${APPDSYM} ]; then
			cp -rf ${APPDSYM} ${DSYM_DIR}/
            echo "DSYM文件导出成功!"
		fi
        
    else  
        echo "版本构建失败......"  
        
        exit 1  
fi 

END_TIME=`date +%s`  
ARCHIVE_TIME="构建版本所耗时间$[ END_TIME - BEGIIN_TIME ]秒"


BEGIIN_TIME=`date +%s`


echo "开始导出ipa包"

xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH} -exportOptionsPlist ${EXPORTOPTION_PATH} -exportPath ${EXPORT_DIR} -allowProvisioningUpdates -quiet >> ${LOGPATH} 
  
EXPORT_IPA=${EXPORT_DIR}/${PROJECT_SCHEME}.ipa 

#如果是文件则说明成功  
if [ -f ${EXPORT_IPA} ]  
    then  
        echo "导出ipa成功!" 
        open ${EXPORT_DIR} 
else  
        echo "ipa导出失败......"  
        exit 1  
fi  

END_TIME=`date +%s`
EXPORT_IPA_TIME="导出ipa所耗时间$[ END_TIME - BEGIIN_TIME ]秒"

echo "时间消耗"
echo "$ARCHIVE_TIME" 
echo "$EXPORT_IPA_TIME" 


echo "开始上传ipa到AppStore"

#验证并上传到App Store
# 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
echo "开始ipa验证"
"$altoolPath" --validate-app -f ${EXPORT_IPA} -u studyonline@china-start.cn -p Study2018 

echo "开始上传"
"$altoolPath" --upload-app -f ${EXPORT_IPA} -u  studyonline@china-start.cn -p Study2018 

echo "你好牛逼啊！！！！！！"
