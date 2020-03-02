#!/bin/bash
read -p "请输入打包项目根目录(绝对路径):" PROJECT_DIR
cd ${PROJECT_DIR}
echo "cd进入项目根目录:${PROJECT_DIR}"
echo "当前路径:"
pwd

read -p "请输入项目名字:" PROJECT_NAME

read -p "请输入项目Scheme:" PROJECT_SCHEME
read -p "请输入项目Build_Configuration:" BUILD_CONFIGURATION
read -p "请输入ExportOption文件绝对路径地址:" EXPORTOPTION_PATH


WORKSPACE_FILE=${PROJECT_NAME}.xcworkspace


#INFOPLIST_PATH=${PROJECT_DIR}/${PROJECT_NAME}/info.plist
#修改Version版本号
#/usr/libexec/PlistBuddy -c "Set CFBundleVersion 1.1.0" ${INFOPLIST_PATH}
#echo "设置成功"
#NEWVERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${INFOPLIST_PATH})
#echo "NEWVERSION ${NEWVERSION}"


LASTESTTWOCOMMITLOG=$(git log -2)


echo "移除并创建新的打包输出相关文件夹"

EXPORTBASEDIR=${PROJECT_NAME}_${BUILD_CONFIGURATION}_Output

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

pod install


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
        
        if [ -f ${APPDSYM} ];then
			cp -rf ${APPDSYM} ${DSYM_DIR}/
            echo "DSYM文件导出成功!"
		else
			rm -rf /data/filename
		fi
        
    else  
        echo "版本构建失败......"  
        exit 1  
fi 

END_TIME=`date +%s`  
ARCHIVE_TIME="构建版本所耗时间$[ END_TIME - BEGIIN_TIME ]秒"


BEGIIN_TIME=`date +%s`
echo "开始导出ipa包"

xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH} -exportOptionsPlist ${EXPORTOPTION_PATH} -exportPath ${EXPORT_DIR} -quiet >> ${LOGPATH}
  
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

EXPORT_IPA_TIME="导出ipa所耗时间$[ END_TIME - BEGIIN_TIME ]秒"


echo "开始上传ipa到蒲公英"


curl -F "file=@${EXPORT_IPA}" -F "uKey=7a8bb651464e7997d6c2e3784e619e55" -F "_api_key=194f0102b96fbaf89e41591efe9144a1" -F "updateDescription=${LASTESTTWOCOMMITLOG}" https://qiniu-storage.pgyer.com/apiv1/app/upload --verbose 


echo "时间消耗"
echo "$ARCHIVE_TIME" 
echo "$EXPORT_IPA_TIME" 

echo "你好牛逼啊！！！！！！"










