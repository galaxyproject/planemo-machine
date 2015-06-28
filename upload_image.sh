time=`date +%Y%m%d`
if [ -e $GALAXY_ORVAL_KEY ]; 
then
    key_args="-i $GALAXY_ORVAL_KEY"
else
    key_args=""
fi
BOX=${BOX:-packer_virtualbox-iso-vagrant_virtualbox.box}
EXTENSION="${BOX#*.}"
REMOTE_ROOT=${REMOTE_ROOT:-/srv/nginx/images.galaxyproject.org/root}
SUFFIX=${SUFFIX:-""}
NAME=$time$SUFFIX.$EXTENSION
scp $key_args $BOX sites@orval.galaxyproject.org:$REMOTE_ROOT/planemo/$NAME
ssh $key_args sites@orval.galaxyproject.org bash -c "cd $REMOTE_ROOT/planemo && ln -f -s $NAME latest.$EXTENSION"
