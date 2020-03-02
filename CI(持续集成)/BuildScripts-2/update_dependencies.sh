#bin/bash - 1
export LANG=en_US.UTF-8
export LANGUAGE=en.US.UTF-8
export LC_ALL=en_US.UTF-8

#设置打包属性
PROJECTPATH=$WORKSPACE"/SRC"
ZMKChannelManager_BRANCH="reconigze"

AIClassroomKit_BRANCH="sdk-test"
ZMPKit_BRANCH="optimizing"
ZMPLib_BRANCH="feature/AIClassRoomSDK"
ZMPJY_BRANCH="develop"
ZMKChannelManager_BRANCH="reconigze"
ZMYAnalyse_BRANCH="1.4.24"


cd $PROJECTPATH


ZMChannelManager=../ZMChannelManager

AIClassroomKit=../AIClassroomKit
ZMPKit=../ZMPKit
ZMPLib=../ZMPLib
ZMPJY=../ZMPJY
ZMYAnalyse=../ZMYAnalyse


#ZMChannelManager
cd $PROJECTPATH

if [ -d ${ZMChannelManager} ];then

if [ "`ls -A ${ZMChannelManager}`" = "" ];
then
    echo "${ZMChannelManager} is  empty"
    git clone -branch ${ZMKChannelManager_BRANCH} git@gitlab.zmaxis.com:ios/zmchannelmanager.git ${ZMChannelManager}
else
    echo "${ZMChannelManager} is not empty"
    cd ${ZMChannelManager}
    #git checkout master
    #git pull
    #git checkout ${ZMChannelManager_TAG}
    #--all

    git pull
    git checkout  ${ZMKChannelManager_BRANCH}
    git pull
fi
else
git clone -b ${ZMKChannelManager_BRANCH} git@gitlab.zmaxis.com:ios/zmchannelmanager.git ${ZMChannelManager}
fi
echo "ZMChannelManager:$(git log -2)"


#AIClassroomKit
cd $PROJECTPATH
if [ -d ${AIClassroomKit} ];then

if [ "`ls -A ${AIClassroomKit}`" = "" ];
then
    echo "${AIClassroomKit} is  empty"
    git clone -b ${AIClassroomKit_BRANCH} git@gitlab.zmaxis.com:genius/aiclassroomkit.git ${AIClassroomKit}
else
    echo "${AIClassroomKit} is not empty"
    cd ${AIClassroomKit}
    git pull
    git checkout  ${AIClassroomKit_BRANCH}
    git pull origin ${AIClassroomKit_BRANCH}
fi
else
    git clone -b ${AIClassroomKit_BRANCH} git@gitlab.zmaxis.com:genius/aiclassroomkit.git ${AIClassroomKit}
fi

echo "AIClassroomKit:$(git log -2)"

#ZMPKit
cd $PROJECTPATH
if [ -d ${ZMPKit} ];then

if [ "`ls -A ${ZMPKit}`" = "" ];
then
    echo "${ZMPKit} is  empty"
    git clone -b ${ZMPKit_BRANCH} git@gitlab.zmaxis.com:zma-kids-iOS/zmpkit.git ${ZMPKit}
else
    echo "${ZMPKit} is not empty"
    cd ${ZMPKit}
    git pull
    git checkout  ${ZMPKit_BRANCH}
    git pull origin ${ZMPKit_BRANCH}
fi
else
    git clone -b ${ZMPKit_BRANCH} git@gitlab.zmaxis.com:zma-kids-iOS/zmpkit.git ${ZMPKit}
fi

echo "ZMPKit:$(git log -2)"

#ZMPJY
cd $PROJECTPATH
if [ -d ${ZMPJY} ];then

if [ "`ls -A ${ZMPJY}`" = "" ];
then
    echo "${ZMPJY} is  empty"
    git clone -b ${ZMPJY_BRANCH} git@gitlab.zmaxis.com:zma-parents-iOS/zmpjy.git ${ZMPJY}
else
    echo "${ZMPJY} is not empty"
    cd ${ZMPJY}
    git pull
    git checkout  ${ZMPJY_BRANCH}
    git pull origin ${ZMPJY_BRANCH}
fi
else
    git clone -b ${ZMPJY_BRANCH} git@gitlab.zmaxis.com:zma-parents-iOS/zmpjy.git ${ZMPJY}
fi

echo "ZMPJY:$(git log -2)"

#ZMYAnalyse
cd $PROJECTPATH
if [ -d ${ZMYAnalyse} ];then

if [ "`ls -A ${ZMYAnalyse}`" = "" ];
then
    echo "${ZMYAnalyse} is  empty"
    git clone -b ${ZMYAnalyse_BRANCH} git@gitlab.zmaxis.com:ios/zmyanalyse.git ${ZMYAnalyse}
else
    echo "${ZMYAnalyse} is not empty"
    cd ${ZMYAnalyse}
    git pull
    git checkout  ${ZMYAnalyse_BRANCH}
    git pull origin ${ZMYAnalyse_BRANCH}
fi
else
    git clone -b ${ZMYAnalyse_BRANCH} git@gitlab.zmaxis.com:ios/zmyanalyse.git ${ZMYAnalyse}
fi

echo "ZMYAnalyse:$(git log -2)"

#ZMPLib
cd $PROJECTPATH
if [ -d ${ZMPLib} ];then

if [ "`ls -A ${ZMPLib}`" = "" ];
then
    echo "${ZMPLib} is  empty"
    git clone -b ${ZMPLib_BRANCH} git@gitlab.zmaxis.com:zma-parents-iOS/zmplib.git ${ZMPLib}
else
    echo "${ZMPLib} is not empty"
    cd ${ZMPLib}
    git pull
    git checkout  ${ZMPLib_BRANCH}
    git pull origin ${ZMPLib_BRANCH}
fi
else
    git clone -b ${ZMPLib_BRANCH} git@gitlab.zmaxis.com:zma-parents-iOS/zmplib.git ${ZMPLib}
fi

echo "ZMPLib:$(git log -2)"

cd $PROJECTPATH

rm -r "../ExportPlists"
cp -r "./BuildScripts/ExportPlists" "../ExportPlists"

rm Podfile.lock
/usr/local/bin/pod install

echo "代码 已经更新完毕..........."

