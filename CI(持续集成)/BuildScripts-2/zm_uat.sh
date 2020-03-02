export LC_ALL=en_US.UTF-8
export BUILD_SCHEME="ZMBrainTrainPad(UAT)"
export EXPORT_SET=""

if [ -f ${WORKSPACE}"/SRC/BuildScripts/build.sh" ];
then
    ${WORKSPACE}"/SRC/BuildScripts/build.sh"
    if [ $? -ne 0 ];
    then
        echo "failed"
        exit 1
    fi
else
    echo '缺少build.sh'
fi

#exportFile=${WORKSPACE}"/report.xlsx"
#cd /Users/jks/Documents/appstoreprereview2
#python export_appreport.py ${WORKSPACE}"/output/Release/ZMKidPadIH.ipa" ${exportFile}


echo "-----ZIP压缩开始-------"
cd ${WORKSPACE}
zip -r ${env}".zip" output/Release/**.ipa
echo "----"${env}".zip压缩完成----"

if [ -f ${WORKSPACE}"/SRC/BuildScripts/apphost_publish_uat.sh" ];
then
    ${WORKSPACE}"/SRC/BuildScripts/apphost_publish_uat.sh"
else
    echo '不需要上传fir'
fi
