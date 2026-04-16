#!/bin/bash
while true; do
  pgrep Xtigervnc > /dev/null || vncserver :1 -geometry 1024x768 -depth 24
  sleep 10
done
