#!/bin/bash

while getopts m:r:d:u:p:c:h option
do
case "${option}"
in
m) MODE=${OPTARG};;
r) RELEASE=${OPTARG};;
d) DB=${OPTARG};;
u) DBUSER=${OPTARG};;
p) DBPASS=${OPTARG};;
c) PFILE=${OPTARG};;
h) HELP="true"
esac
done

if [ -n "$HELP" ]; 
then
 echo "DB toolkit"
 echo
 echo "./release_manage.sh mode -m apply|revert -r release -u username -p password -d tnsname|ezconnect" 
 echo "-m: apply mode. apply - apply release. revert - revert release"
 echo "-r: release id. '-r 000011'"
 echo "-d: db connection string. default no string (local db)"
 echo "-u: db username."
 echo "-p: db password"
 echo "-c: db.properties pathname" 
 echo
fi

RELEASE_NAME=$(echo $RELEASE | awk 'BEGIN {FS=":"}{print $1}')

if [ -z "$RELEASE_NAME" ]; then
  echo "No release to apply/revert is specified. Terminating."
  echo
  exit -1
fi

if [ ! -z "$PFILE" ]; then
 echo "Using $PFILE properties file. -u/-p/-d keys values are ignored."
 echo
 source "$PFILE"
else
 echo "No db.properties file is specified. Trying to use -u/-p/-d values."
fi

if [ -z $DBUSER ]; then
  echo "No database credentials were provided. Terminating."
  exit -1
fi

echo "Going to $MODE release $RELEASE_NAME to $DBUSER/***@$DB"
echo

#todo: properly check sqlpus is avaialble. This construction doesn't always work well
SQLP=$(which sqlplus 2>>/dev/null)

if [ -x "$SQLP" ]; then
 echo "sqlplus found. Proceeding..."
 echo
else
 echo "sqlplus not found. Terminating"
 echo
 exit -1
fi

SQLP="${SQLP} -L"


if [ "$MODE" = "apply" ]; then
    echo "Applying release: $RELEASE_NAME"

    $SQLP $DBUSER/$DBPASS@$DB @Releases/apply-release-$RELEASE_NAME.sql |tee -a  apply.out

    echo "Release $RELEASE_NAME applied"
fi

if [ "$MODE" = "revert" ]; then
    echo "Reverting release $RELEASE_NAME"

    $SQLP $DBUSER/$DBPASS@$DB @Releases/revert-release-$RELEASE_NAME.sql |tee -a revert.out
    
    echo "Release $RELEASE_NAME applied"
fi
