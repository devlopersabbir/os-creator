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

VOLUME_NAME="${VPS_NAME}_data"

echo "Creating volume: $VOLUME_NAME"
docker volume create $VOLUME_NAME

echo "Building Docker image..."
docker build -t debian-ssh-img .

# Create container with unlimited privileges (so sudo works)
docker run -d \
  --name $VPS_NAME \
  --cpus="$CPU" \
  --memory="$RAM" \
  --pids-limit=500 \
  -v $VOLUME_NAME:/home \
  -p 2222:22 \
  --restart always \
  debian-ssh-img

echo "Setting user..."

docker exec -it $VPS_NAME bash -c "
  useradd -m -s /bin/bash $USERNAME
  echo '$USERNAME:$PASSWORD' | chpasswd
  usermod -aG sudo $USERNAME
"

echo "VPS CREATED SUCCESSFULLY!"
echo "SSH command:"
echo "ssh $USERNAME@YOUR_SERVER_IP -p 2222"

