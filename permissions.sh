#!/bin/bash
chmod 755 android/gradlew 
chmod -R 0777 /tmp
chmod 777 /tmp/metro-cache
chown -R root:users /tmp/metro-cache
chown -R root:users node_modules
