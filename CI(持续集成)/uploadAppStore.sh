#验证并上传到App Store
# 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
echo "开始验证"
"$altoolPath" --validate-app -f /Users/zhouyijin/Desktop/ShengXueRelease/ShengXue.ipa -u studyonline@china-start.cn -p Study2018 

echo "开始上传"
"$altoolPath" --upload-app -f /Users/zhouyijin/Desktop/ShengXueRelease/ShengXue.ipa -u  studyonline@china-start.cn -p Study2018 