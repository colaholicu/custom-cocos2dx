SHELL_DIR=$(cd "$(dirname "$0")"; pwd)

pushd ${SHELL_DIR}

TARGET_DIR_NAME="publish"

if [ ! ${PLUGIN_ROOT} ]; then
    pushd ../
    PLUGIN_ROOT=`pwd`
    popd
fi

TARGET_ROOT=${PLUGIN_ROOT}/${TARGET_DIR_NAME}

#check the environment
source ./../../../proj.android/env.sh


if [ $1 == 'protocols' ] ; then
	echo
	echo "Now publishing protocols"
	echo ---------------------------------
	./toolsForPublish/publishPlugin.sh "protocols" ${TARGET_ROOT} ${PLUGIN_ROOT}
	echo ---------------------------------
else
	echo
	echo Now publish $1
    echo ---------------------------------
    ./toolsForPublish/publishPlugin.sh "plugins/"$1 ${TARGET_ROOT} ${PLUGIN_ROOT}
    echo ---------------------------------
fi

popd
