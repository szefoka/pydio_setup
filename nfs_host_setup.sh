IP=$1
SHARED_DIR=$2

apt-get update
apt-get install -y nfs-kernel-server 

#use NFSv3
sed -i 's/RPCNFSDCOUNT=8/RPCNFSDCOUNT="8 --no-nfs-version 4"/'  /etc/default/nfs-kernel-server
systemctl restart nfs-kernel-server

mkdir -p $SHARED_DIR
chown -R www-data:www-data $SHARED_DIR
chown nobody:nogroup /users/szefoka/measurements
echo "$SHARED_DIR    $IP(rw,sync,no_subtree_check)" > /etc/exports
sudo systemctl restart nfs-kernel-server
