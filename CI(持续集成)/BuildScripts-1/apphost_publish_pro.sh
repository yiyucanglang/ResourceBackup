echo "要准备上传到APPHOST上面啦！-------------->"
cd ${WORKSPACE}

dingdingNotificationJsonPath=/${WORKSPACE}/output/Release/jenkinsToDingding.json
touch ${dingdingNotificationJsonPath}

firPublishLog=""
FIR_LOG_TEXT=${REMARK}
plat_id=84
ipa_path="output/Release/ZMBrainTrainPad.ipa"


json=`curl --form plat_id=${plat_id}  --form token=8560e331708472cec3400c7122c7bea95f5dfdf6 --form features=${REMARK} --form file=@${ipa_path} https://apphost.zmlearn.com/api/pkgs`
id=`echo $json | jq .id`
url=https://apphost.zmlearn.com/pkgs/${id}
echo $url
echo $url > apphost_url.txt

echo " 🎉  🎉  🎉 上传成功------狂拽炫酷吊炸天！！！！！！ biu~biu~biu~ 🎉  🎉  🎉"

appVersion=""
PRODUCT_NAME="掌门小天才HD"
echo ${WORKSPACE}

appWebUrl="https://apphost.zmlearn.com/apps/29/plats/84"

PROJECT_DIR=$WORKSPACE/SRC
cd ${PROJECT_DIR}

LASTESTCOMMITLOG=""
LASTESTCOMMITLOG=${LASTESTCOMMITLOG}$(git log -3)

#生成通知钉钉的消息Json
funcDingdingNotificationJson() {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~ #生成通知钉钉的消息Json ~~~~~~~~~~~~~~~~~~~~~~~~"
    funcCombiningUpdateLogString true
    PRODUCT_NAME=${PRODUCT_NAME}
    PRODUCT_VERSION=${appVersion}
    BUILD_VERSION="0"
    iconUrl="https://apphost.zmlearn.com/uploads/pkg/icon/1121/AppIcon40x40_2x_ipad.png"
    markdownText=" \
    # $PRODUCT_NAME \\n \
    ![logo]($iconUrl) \\n \\n \
    智能打包安装链接：**[$appWebUrl]($appWebUrl)** \\n\\n \
    日期：**`date +%Y-%m-%d,%H:%M`** \\n\\n \
    版本：**version: $PRODUCT_VERSION build: $BUILD_VERSION**  \\n\\n \
    系统：**iOS 9.0及以上** \\n\\n \
    更新日志: \\n \
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
