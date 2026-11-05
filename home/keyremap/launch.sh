#!/usr/bin/env zsh
# https://hidutil-generator.netlify.app

cp com.local.keyremap.plist ~/Library/LaunchAgents/com.local.keyremap.plist

launchctl load ~/Library/LaunchAgents/com.local.keyremap.plist
