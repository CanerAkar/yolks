#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Check if MSH Config file exists
if [ ! -s /home/container/msh-config.json ]; then
    echo -e "Downloading MSH msh-config.json"
    curl -o /home/container/msh-config.json https://gist.githubusercontent.com/BolverBlitz/fa895e8062fcab7dd7a54d768843a261/raw/7224a0694a985ba1bff0b4fe9b44f2c79e9b495e/msh-config.json
fi

# Set the URL and file paths
URL=https://downloads.fps.ms/msh_server.bin
LOCAL_FILE=/home/container/msh_server.bin

# Check if MSH Bin file exists
if [ ! -f $LOCAL_FILE ]; then
    echo -e "Downloading MSH msh_server.bin"
    curl -o $LOCAL_FILE $URL
else
    # Get the SHA256 hash of local and remote files
    LOCAL_HASH=$(sha256sum $LOCAL_FILE | awk '{print $1}')
    REMOTE_HASH="68D4FCE67F5B5A9365EB40C793D235AEBC99AEE6F3B368F972B08D90DFC72589"

    # Compare hashes and download if different
    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        echo -e "Hashes differ. Downloading updated MSH msh_server.bin"
        curl -o $LOCAL_FILE $URL
    else
        echo -e "Hashes match. No need to download."
    fi
fi

chmod u+x $LOCAL_FILE

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}