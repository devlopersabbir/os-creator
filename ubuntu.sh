#!/bin/bash

echo -n "Enter VPS name: "
read VPS_NAME

echo -n "Enter username: "
read USERNAME

echo -n "Enter password: "
read -s PASSWORD
echo

echo -n "CPU Limit (example 1): "
read CPU

echo -n "RAM Limit (example 1g): "
read RAM

echo -n "Disk (GB example 10): "
read DISK

echo -n "Enter SSH port (example 2222): "
read SSHPORT

VOLUME_NAME="${VPS_NAME}_data"

echo "Creating volume: $VOLUME_NAME"
docker volume create $VOLUME_NAME

echo "Building Ubuntu VPS image..."
docker build -t ubuntu-ssh-img -f Dockerfile.ubuntu .

# Run container
docker run -d \
  --name $VPS_NAME \
  --cpus="$CPU" \
  --memory="$RAM" \
  --pids-limit=500 \
  -v $VOLUME_NAME:/home \
  -p $SSHPORT:22 \
  --restart always \
  ubuntu-ssh-img

echo "Creating user inside VPS..."
docker exec -it $VPS_NAME bash -c "
  useradd -m -s /bin/bash $USERNAME
  echo '$USERNAME:$PASSWORD' | chpasswd
  usermod -aG sudo $USERNAME
"

echo "✅ VPS CREATED SUCCESSFULLY!"
echo "SSH command:"
echo "ssh $USERNAME@10.10.20.56 -p $SSHPORT"

