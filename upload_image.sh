time=`date +%Y%m%d`
if [ -e $GALAXY_ORVAL_KEY ]; 
then
    key_args="-i $GALAXY_ORVAL_KEY"
else
    key_args=""
fi
BOX=${BOX:-packer_virtualbox-iso_virtualbox.box}
REMOTE_ROOT=${REMOTE_ROOT:-/srv/nginx/images.galaxyproject.org/root}

scp $key_args $BOX sites@orval.galaxyproject.org:$REMOTE_ROOT/planemo/$time.box
ssh $key_args sites@orval.galaxyproject.org bash -c "cd $REMOTE_ROOT/planemo; ln -f -s $time.box latest.box"

