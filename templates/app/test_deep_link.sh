#!/bin/bash

# Default values
SCHEME="glue"
HOST="example.com"
PATH="/example"
PARAMS="title=Test&isModal=true"

# Check if custom parameters were provided
if [ ! -z "$1" ]; then
    PARAMS=$1
fi

# Construct the URL
URL="$SCHEME://$HOST$PATH?$PARAMS"

# Open the URL in the simulator
xcrun simctl openurl booted "$URL"

echo "Opened deep link: $URL"
