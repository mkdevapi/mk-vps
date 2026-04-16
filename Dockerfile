FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=10000
ENV DISPLAY=:1

# Install minimal GUI + VNC + noVNC
RUN apt update && apt install -y \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server \
    novnc websockify \
    dbus-x11 x11-xserver-utils \
    xterm wget curl nano htop \
    && apt clean

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    echo "password" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Fix noVNC default page
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# FIX XFCE START (IMPORTANT)
RUN echo '#!/bin/bash\nstartxfce4 &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Copy scripts
COPY start.sh /start.sh
COPY keepalive.sh /keepalive.sh
COPY watchdog.sh /watchdog.sh

RUN chmod +x /start.sh /keepalive.sh /watchdog.sh

EXPOSE 10000

CMD ["/bin/bash", "/start.sh"]
