#! /bin/sh

imageName=dpage/pgadmin4
containerName=pgadmin

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

CONF_DIR=$LOCAL_DIR/admin-conf
LOG_DIR=$LOCAL_DIR/admin-log

# ensure the folders exist
for dir in $CONF_DIR $LOG_DIR
do
    [ -d $dir ] || mkdir $dir
done

# root password
rootUser=drsaaron@gmail.com
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

# start 'er up.  runs as root and does not mount anything so nothing
# is persisted container to container.  For some reason can't simply
# add --user with mounts, because that doesn't add the user to the
# passwd DB.
#
# see https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html#mapped-files-and-directories
# for possible solution
docker run -d \
       --name $containerName \
       --network qotd \
       -p 5051:80 \
       -e "PGADMIN_DEFAULT_EMAIL=$rootUser" \
       -e "PGADMIN_DEFAULT_PASSWORD=$rootPassword" \
       $imageName:$today

