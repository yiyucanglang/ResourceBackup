export LC_ALL=en_US.UTF-8
export BUILD_SCHEME="ZMBrainTrainPad(TEST)"
export EXPORT_SET=""
echo ${WORKSPACE}


PROJECTPATH=${WORKSPACE}"/SRC"


#cd ${PROJECTPATH}
#cd ZMKidPad/Assets.xcassets/AppIcon.appiconset
#for element in `ls | grep png`
#do
#    echo ${element}
#    python /Users/jks/Documents/appstoreprereview2/addversion.py ${element} ${version}
#done


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
    exit 1
fi

echo "-----ZIP压缩开始-------"
cd ${WORKSPACE}
zip -r ${env}".zip" output/Release/**.ipa
echo "----"${env}".zip压缩完成----"

if [ -f ${WORKSPACE}"/SRC/BuildScripts/apphost_publish.sh" ];
then
    ${WORKSPACE}"/SRC/BuildScripts/apphost_publish.sh"
else
    echo '不需要上传fir'
fi
