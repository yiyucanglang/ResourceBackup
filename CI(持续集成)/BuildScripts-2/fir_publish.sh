echo "要准备上传到Fir上面啦！-------------->"
cd ${WORKSPACE}

dingdingNotificationJsonPath=/${WORKSPACE}/output/Release/jenkinsToDingding.json
touch ${dingdingNotificationJsonPath}

firPublishLog=""
FIR_LOG_TEXT=${REMARK}

#发布到fir.im
if [ "${BUILD_SCHEME}" = "ZMKidPadIH" ]
then
firPublishLog=`fir publish output/Release/ZMKidPadIH.ipa --token=5089102f9dda232e58548a1beb52d8da --changelog=${FIR_LOG_TEXT}`

else
firPublishLog=`fir publish output/Release/ZMKidPad.ipa --token=5089102f9dda232e58548a1beb52d8da --changelog=${FIR_LOG_TEXT}`
fi

echo ${firPublishLog}
echo " 🎉  🎉  🎉 上传成功------狂拽炫酷吊炸天！！！！！！ biu~biu~biu~ 🎉  🎉  🎉"

appVersion=""
PRODUCT_NAME=""
echo ${WORKSPACE}
PROJECTPATH=${WORKSPACE}"/SRC"
IHplistFile=$PROJECTPATH"/ZMKidPadIH-Info.plist"
plistFile=$PROJECTPATH"/ZMKidPad/info.plist"

if [ "${BUILD_SCHEME}" = "ZMKidPadIH" ]
then
    appVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${IHplistFile})
    PRODUCT_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" ${IHplistFile})
else
    appVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${plistFile})
    PRODUCT_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName" ${plistFile})
fi

echo "appVersion====${appVersion}"
echo "PRODUCT_NAME====${PRODUCT_NAME}"

#生成通知钉钉的消息Json
funcDingdingNotificationJson() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~ #生成通知钉钉的消息Json ~~~~~~~~~~~~~~~~~~~~~~~~"
    funcRequestFirApplicationInfomation
    #funcCombiningNeedAtContactsString
    funcCombiningUpdateLogString true
    PRODUCT_NAME=${PRODUCT_NAME}
    PRODUCT_VERSION=${appVersion}
    BUILD_VERSION="0"
    iconUrl="https://web-data.zmlearn.com/image/voVg3c1ZLrJkML6J52zMoz/76@2x.png"
    markdownText=" \
    # $PRODUCT_NAME \\n \
    ![logo]($iconUrl) \\n \\n \
    安装链接：**[$appWebUrl]($appWebUrl)** \\n\\n \
    日期：**`date +%Y-%m-%d,%H:%M`** \\n\\n \
    版本：**version: $PRODUCT_VERSION build: $BUILD_VERSION**  \\n\\n \
    系统：**iOS 9.0及以上** \\n\\n \
    更新日志: \\n \
    $updateLog"

    jsonText="{\"msgtype\": \"markdown\",\
    \"markdown\": \
    {\"title\":\"$PRODUCT_NAME\",\"text\":\"$markdownText\"}, \
    \"at\": {\"atMobiles\": [$atContactsJson]}}"

    echo "------------------------jsonText:${jsonText}"
    #写入文件
    echo $jsonText> $dingdingNotificationJsonPath
    #cp -rf ${dingdingNotificationJsonPath} ${baseOutputDirectory}/

    #结束时间
    END_TIME=`date +%s`
    PREPARE_JSON_TIME="准备通知钉钉的所耗时间$[ END_TIME - BEGIIN_TIME ]秒"
}


#拼接打包的更新日志（fir.im、钉钉消息）
#$1 bool   是否拼接markdown字符串
#updateLog 拼接好的日志字符串
funcCombiningUpdateLogString() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~ 拼接打包的更新日志 ~~~~~~~~~~~~~~~~~~~~~~~~"
    index=1
    updateLog=""
    for item in $FIR_LOG_TEXT;
    do
        updateLog="${updateLog} ${index}. ${item}"
        if [ $1 == true ]
        then
            updateLog="${updateLog}\\n"
        else
            updateLog="${updateLog}\n"
        fi
        number=$(($index+1))
    done
}

#请求应用详细信息
funcRequestFirApplicationInfomation() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~ 请求应用详细信息 ~~~~~~~~~~~~~~~~~~~~~~~~"#
    #起始时间
    BEGIIN_TIME=`date +%s`

    iconUrl=""
    appWebUrl=""

    #提取appId
    tempStr=${firPublishLog#*App id is }
    appId=${tempStr%%[[:space:]]*}
    #提取release id
    tempStr=${firPublishLog#*Release id is }
    releaseId=${tempStr%%[[:space:]]*}
    #提取短链
    tempStr=${firPublishLog#*Published succeed: }
    shortUrlStr=${tempStr%%[[:space:]]*}

    #请求应用详细信息
    response=`curl http://api.fir.im/apps/${appId}?api_token=5089102f9dda232e58548a1beb52d8da`
    #提取图标地址
    #iconUrl=`echo -e ${response} | jq --raw-output .icon_url`
    #提取短链接名
    #shortName=`echo -e ${response} | jq --raw-output .short`

    #拼接应用详情地址
    #appWebUrl="https://fir.im/${shortName}?release_id=${releaseId}"
    appWebUrl="${shortUrlStr}?release_id=${releaseId}"

    echo "拼接应用详情地址为：${appWebUrl}"
}

#发送钉钉消息
funcPostDingdingMessage() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~ 发送钉钉消息 ~~~~~~~~~~~~~~~~~~~~~~~~"

    if [ -f ${dingdingNotificationJsonPath} ]
    then
    #起始时间
        BEGIIN_TIME=`date +%s`
    url="https://oapi.dingtalk.com/robot/send?access_token=41bcc874ae0f5f8e9168876195d6556e6e61eec330a7c822940e4df89577fedf"
        response=`curl -X "POST" "${url}" \
        -H "Content-Type: application/json" \
        -d @${dingdingNotificationJsonPath} \
        `
        echo ${response}
        #结束时间
        END_TIME=`date +%s`
        NOTIFY_DINGDING_TIME="通知钉钉的所耗时间$[ END_TIME - BEGIIN_TIME ]秒"
        
        echo ${NOTIFY_DINGDING_TIME}

    else
        echo "${dingdingNotificationJsonPath}为空"
    fi
}


funcDingdingNotificationJson
funcPostDingdingMessage
