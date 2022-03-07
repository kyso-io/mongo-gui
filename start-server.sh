#!/bin/sh
if [ "$URL" ]; then
  exec node server.js -u "${URL}" -p "${PORT:-4321}"
else
  echo "Missing URL variable, please add it" 1>&2
  exit 1
fi
