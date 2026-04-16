FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=10000

# Install lightweight + useful tools
RUN apt update && apt install -y \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server \
    novnc websockify \
    xterm wget curl git nano htop \
    dbus-x11 \
    && apt clean

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    echo "password" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Fix noVNC default page
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Improve startup (faster XFCE)
RUN echo "#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
startxfce4 &\n" > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# 🔥 KEEP ALIVE (anti sleep)
RUN echo '#!/bin/bash\n\
while true; do \
  curl -s http://localhost:$PORT > /dev/null; \
  sleep 25; \
done' > /keepalive.sh && chmod +x /keepalive.sh

# 🔥 AUTO RESTART VNC if crash
RUN echo '#!/bin/bash\n\
while true; do \
  pgrep Xtigervnc > /dev/null || vncserver :1 -geometry 1024x768 -depth 24; \
  sleep 10; \
done' > /watchdog.sh && chmod +x /watchdog.sh

# 🔥 START SCRIPT (optimized)
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
vncserver :1 -geometry 1024x768 -depth 24\n\
/keepalive.sh & \
/watchdog.sh & \
websockify --web=/usr/share/novnc/ ${PORT} localhost:5901\n' > /start.sh && chmod +x /start.sh

EXPOSE 10000

CMD ["/bin/bash", "/start.sh"]
