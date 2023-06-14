#! /bin/sh

imageName=dpage/pgadmin4

if pullLatestDocker.sh -i $imageName
then
    # building new container
    echo "building new container"
    createAdminContainer.sh
    purgeOldImages.sh -i $imageName
else
    echo "no image update, so nothing more to do"
    exit 1
fi
