echo "要准备上传到APPHOST上面啦！-------------->"
cd ${WORKSPACE}

dingdingNotificationJsonPath=/${WORKSPACE}/output/Release/jenkinsToDingding.json
touch ${dingdingNotificationJsonPath}


PROJECT_SCHEME=${BUILD_SCHEME}
echo "${PROJECT_SCHEME}"

PRODUCT_NAME=""
appWebUrl=""
plat_id=82
ipa_path=""

if [[ ${PROJECT_SCHEME} =~ "(TEST)" ]]; then

PRODUCT_NAME="掌门小天才HD-TEST"
appWebUrl="https://apphost.zmlearn.com/apps/29/plats/82"
plat_id=82
ipa_path="output/Release/ZMBrainTrainPad(TEST).ipa"

elif [[ ${PROJECT_SCHEME} =~ "(UAT)" ]]; then

PRODUCT_NAME="掌门小天才HD-UAT"
appWebUrl="https://apphost.zmlearn.com/apps/29/plats/83"
plat_id=83
ipa_path="output/Release/ZMBrainTrainPad(UAT).ipa"

else

PRODUCT_NAME="掌门小天才HD"
appWebUrl="https://apphost.zmlearn.com/apps/29/plats/84"
plat_id=84
ipa_path="output/Release/ZMBrainTrainPad.ipa"

fi

echo "${PRODUCT_NAME}"
echo "${appWebUrl}"
echo "${plat_id}"
echo "${ipa_path}"


firPublishLog=""
FIR_LOG_TEXT=${REMARK}


PROJECT_DIR=$WORKSPACE/SRC
cd ${PROJECT_DIR}

LASTESTCOMMITLOG=""
LASTESTCOMMITLOG=${LASTESTCOMMITLOG}$(git log --pretty=format:"%an: %s  %h (%cd)\n\n" --date=iso  -3)


#获取版本号
appVersion=`xcodebuild -showBuildSettings | grep "MARKETING_VERSION" | tr -d 'MARKETING_VERSION ='`
appBuildVersion=`xcodebuild -showBuildSettings | grep "CURRENT_PROJECT_VERSION" | tr -d 'CURRENT_PROJECT_VERSION ='`

echo ${appVersion}
echo ${appBuildVersion}


cd ${WORKSPACE}

json=`curl --form plat_id=${plat_id}  --form token=8560e331708472cec3400c7122c7bea95f5dfdf6 --form features=${REMARK} --form file=@${ipa_path} https://apphost.zmlearn.com/api/pkgs`
id=`echo $json | jq .id`
url=https://apphost.zmlearn.com/pkgs/${id}
echo $url
echo $url > apphost_url.txt

echo " 🎉  🎉  🎉 上传成功------狂拽炫酷吊炸天！！！！！！ biu~biu~biu~ 🎉  🎉  🎉"

echo ${WORKSPACE}


#生成通知钉钉的消息Json
funcDingdingNotificationJson() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~ #生成通知钉钉的消息Json ~~~~~~~~~~~~~~~~~~~~~~~~"
    funcCombiningUpdateLogString true
    PRODUCT_NAME=${PRODUCT_NAME}
    PRODUCT_VERSION=${appVersion}
    BUILD_VERSION=${appBuildVersion}
    markdownText=" \
    # $PRODUCT_NAME \\n \\n\
    智能打包安装链接：**[$appWebUrl]($appWebUrl)** \\n\\n \
    日期：**`date +%Y-%m-%d,%H:%M`** \\n\\n \
    版本：**version: $PRODUCT_VERSION build: $BUILD_VERSION**  \\n\\n \
    系统：**iOS 9.0及以上** \\n\\n \
    更新日志: \\n \\n \
    $LASTESTCOMMITLOG"

    jsonText="{\"msgtype\": \"markdown\",\
    \"markdown\": \
    {\"title\":\"$PRODUCT_NAME\",\"text\":\"$markdownText\"}, \
    \"at\": {\"atMobiles\": [$atContactsJson]}}"

    echo "------------------------jsonText:${jsonText}"
    #写入文件
    echo $jsonText> $dingdingNotificationJsonPath

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

#发送钉钉消息
funcPostDingdingMessage() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~ 发送钉钉消息 ~~~~~~~~~~~~~~~~~~~~~~~~"

    if [ -f ${dingdingNotificationJsonPath} ]
    then
    #起始时间
        BEGIIN_TIME=`date +%s`
    url="https://oapi.dingtalk.com/robot/send?access_token=44774c8a8a22dd38d1860f3dc3f658aed3dbd2c5a1aea117073a03a1ee6acab7"
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
