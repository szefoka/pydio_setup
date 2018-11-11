NFS_HOST=$1
SHARED_DIR=$2
apt-get update
apt-get install nfs-common 
mkdir -p /var/lib/pydio/data/personal/admin/node2
mount $NFS_HOST:$SHARED_DIR /var/lib/pydio/data/personal/admin/node2
