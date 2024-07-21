#!/bin/sh

# Shutdown trap
shutdown() {
    echo "Shutting down SeaDrive..."
    
    # Send SIGTERM to seadrive process
    kill -TERM "$SEADRIVE_PID" 2>/dev/null

    sleep 2
        
    # Unmount FUSE filesystem
    fusermount -u /mnt/
    
    echo "SeaDrive shutdown complete"
    exit 0
}

trap shutdown 15 2



# Get token from Seafile server
TOKEN=$(curl -s -d "username=$SEAFILE_USERNAME" -d "password=$SEAFILE_PASSWORD" "$SEAFILE_SERVER_URL/api2/auth-token/" | jq -r .token)

# Generate random client name if not provided
if [ -z "$SEAFILE_CLIENT_NAME" ]; then
    SEAFILE_CLIENT_NAME="seafile-container-$(uuidgen)"
fi

# Create the config file
cat > /root/seadrive.conf <<EOF
[account]
server = $SEAFILE_SERVER_URL
username = $SEAFILE_USERNAME
token = $TOKEN
is_pro = true

[general]
client_name = $SEAFILE_CLIENT_NAME

[cache]
size_limit = $SEAFILE_CACHE_SIZE
clean_cache_interval = $SEAFILE_CACHE_CLEAN_INTERVAL
EOF

# Start SeaDrive
mkdir -p /root/.seadrive/
seadrive -c /root/seadrive.conf -f -d /root/.seadrive/ -o allow_other,default_permissions /mnt/ &

SEADRIVE_PID=$!
wait $SEADRIVE_PID