#!/bin/sh
# ===========================================================================
# NZBHydra 2 entrypoint for a non-root container (TOS 7 requirement).
#
# The LinuxServer.io image starts the Java application through s6 as root; s6
# cannot run inside a container that already runs as uid 1000. The upstream
# python launcher can prepare and start the jar by itself, so this wrapper calls
# it directly with the data folder on the mounted volume.
# ===========================================================================
set -e
set -u

DATA=/config
mkdir -p "$DATA" 2>/dev/null || true

if ! ( : > "$DATA/.write-test" ) 2>/dev/null; then
  echo "nzbhydra: $DATA is not writable by uid $(id -u)" >&2
  exit 1
fi
rm -f "$DATA/.write-test"

exec python3 /app/hydra2/nzbhydra2wrapperPy3.py \
  --datafolder "$DATA" \
  --port 5076 \
  --nobrowser
