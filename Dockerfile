FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=10000
ENV DISPLAY=:1

# Install minimal + stable GUI
RUN apt update && apt install -y \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server \
    novnc websockify \
    dbus-x11 x11-xserver-utils \
    xterm wget curl \
    && apt clean

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    echo "password" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Fix noVNC default
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Fix XFCE startup (VERY IMPORTANT)
RUN echo '#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
startxfce4 &' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# Keep alive (reduce sleep)
RUN echo '#!/bin/bash\n\
while true; do curl -s http://localhost:$PORT > /dev/null; sleep 20; done' > /keepalive.sh && chmod +x /keepalive.sh

# Watchdog (auto restart VNC)
RUN echo '#!/bin/bash\n\
while true; do \
  pgrep Xtigervnc > /dev/null || vncserver :1 -geometry 1024x768 -depth 24; \
  sleep 10; \
done' > /watchdog.sh && chmod +x /watchdog.sh

# Start script (clean + stable)
RUN echo '#!/bin/bash\n\
vncserver -kill :1 2>/dev/null\n\
vncserver :1 -geometry 1024x768 -depth 24\n\
/keepalive.sh & \
/watchdog.sh & \
websockify --web=/usr/share/novnc/ $PORT localhost:5901\n' > /start.sh && chmod +x /start.sh

EXPOSE 10000

CMD ["/bin/bash", "/start.sh"]
