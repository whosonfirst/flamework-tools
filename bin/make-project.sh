#!/bin/sh

WHOAMI=`python -c 'import os, sys; print os.path.realpath(sys.argv[1])' $0`

WHEREAMI=`dirname $WHOAMI`
TOOLS=`dirname $WHEREAMI`

PROJECT=$1
PROJECT_NAME=`basename ${PROJECT}`

TMP="/tmp/${PROJECT}"

if [ ! -d ${PROJECT} ]
then
    mkdir ${PROJECT}
fi

echo "cloning dependencies"
git clone https://github.com/whosonfirst/flamework.git ${TMP}/

for WHAT in `ls -a ${TMP}`
do
    if [ -z "${WHAT//[^.]/}" ]
    then
	cp -r ${TMP}/${WHAT} ${PROJECT}/${WHAT}
    fi
    
done

rm -rf ${TMP}

echo "# ${PROJECT_NAME}\n" > ${PROJECT}/README.md

echo "removing unnecessary files"

rm -rf ${PROJECT}/www/cron
rm -rf ${PROJECT}/docs
rm -rf ${PROJECT}/tests
rm -f ${PROJECT}/.travis.yml
rm -f ${PROJECT}/Vagrantfile
rm -f ${PROJECT}/LICENSE
rm -f ${PROJECT}/www/paging.php
rm -f ${PROJECT}/www/templates/page_paging.txt


# TODO: figure out if sudo is necessary
# sudo chown -R www-data ${PROJECT}/www/templates_c

echo "setting up apache files"

mkdir -p ${PROJECT}/apache
echo "*.conf" >> ${PROJECT}/apache/.gitignore

cp ${TOOLS}/apache/example.conf ${PROJECT}/apache/${PROJECT_NAME}.conf.example
cp ${TOOLS}/apache/example.conf ${PROJECT}/apache/${PROJECT_NAME}.conf

perl -p -i -e "s!__PROJECT_ROOT__!${PROJECT}!" ${PROJECT}/apache/${PROJECT_NAME}.conf
perl -p -i -e "s!__PROJECT_NAME__!${PROJECT_NAME}!" ${PROJECT}/apache/${PROJECT_NAME}.conf

echo "cloning ubuntu utilities"

cp -r ${TOOLS}/ubuntu ${PROJECT}/

echo "setting up flamework-bin"

cp ${TOOLS}/flamework-bin/*.sh ${PROJECT}/bin/
cp ${TOOLS}/flamework-bin/*.php ${PROJECT}/bin/

echo "setting up .htaccess files"

cp ${TOOLS}/apache/.htaccess-deny ${PROJECT}/apache/.htaccess
cp ${TOOLS}/apache/.htaccess-deny ${PROJECT}/ubuntu/.htaccess
cp ${TOOLS}/apache/.htaccess-deny ${PROJECT}/schema/.htaccess
cp ${TOOLS}/apache/.htaccess-deny ${PROJECT}/bin/.htaccess
cp ${TOOLS}/apache/.htaccess-noindexes ${PROJECT}/.htaccess

echo "setting up (application) config files"

cp ${PROJECT}/www/include/secrets.php.example ${PROJECT}/www/include/secrets.php

echo "setting up .gitignore"

cp ${TOOLS}/git/dotgitignore ${PROJECT}/.gitignore

echo "setting up Makefile"

if [ -f ${PROJECT}/Makefile ]
then
    touch ${PROJECT}/Makefile
fi

echo "" >> ${PROJECT}/Makefile
cat ${TOOLS}/make/Makefile >> ${PROJECT}/Makefile

echo "all done"

exit 0
