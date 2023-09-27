##!/bin/sh
# vim:sw=2:ts=2:et

# Container entrypoint based on the docker-entrypoint.sh script that can be
# found on https://github.com/nginxinc/docker-nginx/tree/master/entrypoint/.
#
# The script runs the *.sh executable files found under the
# /container-entrypoint.d directory if the `CEP_NO_SCRIPTS` variable is empty.
#
# If the variable `CEP_QUIET_LOGS` is set the standar output of this script and
# the ones executed by it.
#
# If there is no failure running the *.sh files or none is found the script
# executes the /usr/bin/dumb-init as the supervisor of the CMD passed to the
# container.

set -e

SCRIPTS_DIR="/container-entrypoint.d/"

if [ -z "${CEP_NO_SCRIPTS}" ]; then
  if [ "${CEP_QUIET_LOGS:-}" ]; then
    exec 3>/dev/null
  else
    exec 3>&1
  fi
  if /usr/bin/find "$SCRIPTS_DIR" -mindepth 1 -maxdepth 1 -type f -print -quit \
      2>/dev/null | read v; then
    echo >&3 "$0: $SCRIPTS_DIR not empty, will try to run scripts"
    echo >&3 "$0: Looking for shell scripts in $SCRIPTS_DIR"
    find "$SCRIPTS_DIR" -follow -type f -print | sort -V | while read -r f; do
      case "$f" in
      *.sh)
        if [ -x "$f" ]; then
          echo >&3 "$0: Launching $f";
          "$f"
        else
          # warn on shell scripts without exec bit
          echo >&3 "$0: Ignoring $f, not executable";
        fi
        ;;
      *) echo >&3 "$0: Ignoring $f";;
      esac
    done
    echo >&3 "$0: Configuration complete; ready to start up"
  else
    echo >&3 "$0: No files in $SCRIPTS_DIR, skipping configuration"
  fi
fi

exec /usr/bin/dumb-init -- "$@"
