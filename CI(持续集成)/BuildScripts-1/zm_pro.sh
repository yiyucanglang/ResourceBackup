export LC_ALL=en_US.UTF-8
export BUILD_SCHEME="ZMBrainTrainPad"
export EXPORT_SET="APPSTORE"


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
#python export_appreport.py ${WORKSPACE}"/output/Release/ZMKidPad.ipa" ${exportFile}


echo "-----ZIP压缩开始-------"
cd ${WORKSPACE}
zip -r ${env}".zip" "output/" > /dev/null
echo "----"${env}".zip压缩完成----"


if [ -f ${WORKSPACE}"/SRC/BuildScripts/apphost_publish_pro.sh" ];
then
    ${WORKSPACE}"/SRC/BuildScripts/apphost_publish_pro.sh"
else
    echo '不需要上传fir'
fi

ipaFile=${WORKSPACE}"/output/Release/ZMKidPad.ipa"

# appstore 脚本上传，如果想开通，请联系张培军，需要到appstore connect配置key，下载私钥配置到打包机上
# xcrun altool --validate-app -f ${ipaFile} -t ios --apiKey 24VCQN3F5P --apiIssuer e8a3bb89-a0c7-49ae-beed-b98625ab9179
# xcrun altool --upload-app -f ${ipaFile} -t ios --apiKey 24VCQN3F5P --apiIssuer e8a3bb89-a0c7-49ae-beed-b98625ab9179
