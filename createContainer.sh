#! /bin/sh

imageName=postgres
containerName=postgres1

while getopts :d: OPTION
do
    case $OPTION in
        d)
            today=$OPTARG
            ;;
        *)
            echo "unknown option $OPTARG" 1>&2
            exit 1
    esac
done

LOCAL_DIR=$(dirname $0)
[ "$LOCAL_DIR" = "." ] && LOCAL_DIR=`pwd`

CONF_DIR=$LOCAL_DIR/conf
DATA_DIR=$LOCAL_DIR/data
KEYRING_DIR=$LOCAL_DIR/keyring
LOG_DIR=$LOCAL_DIR/logs

# ensure the folders exist
for dir in $DATA_DIR 
do
    [ -d $dir ] || mkdir $dir
done

# root password
rootUser=drsaaron
rootPassword=$(pass Database/local-postgres/$rootUser)

# stop and remove existing container
docker stop $containerName
docker rm $containerName

# tag the image with today's date
if [ -z "$today" ]
then
    today=$(date '+%Y%m%d')
    docker tag $imageName:latest $imageName:$today
fi

# start 'er up
docker run -d \
       -e POSTGRES_USER=$rootUser \
       -e POSTGRES_PASSWORD=$rootPassword \
       -p 5432:5432 \
       -v $DATA_DIR:/var/lib/postgresql/data \
       --name $containerName \
       --network qotd \
       --user $(id -u):$(id -g) \
       $imageName:$today
