#!/bin/bash

export DISPLAY=:1

echo "Stopping old VNC..."
vncserver -kill :1 2>/dev/null

echo "Starting VNC..."
vncserver :1 -geometry 1024x768 -depth 24

# WAIT FOR VNC (VERY IMPORTANT)
sleep 5

# CHECK VNC RUNNING
pgrep Xtigervnc || (echo "VNC failed to start!" && exit 1)

echo "VNC started successfully!"

# Start background services
/keepalive.sh &
/watchdog.sh &

echo "Starting noVNC..."

# Start noVNC (MAIN PROCESS)
exec websockify --web=/usr/share/novnc/ $PORT localhost:5901
