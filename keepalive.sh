#!/bin/bash
while true; do
  curl -s http://localhost:$PORT > /dev/null
  sleep 20
done
