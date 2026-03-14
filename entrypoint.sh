#!/bin/bash
set -e

rm -f /girigiri/tmp/pids/server.pid

exec "$@"