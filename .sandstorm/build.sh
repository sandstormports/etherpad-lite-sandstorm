#!/bin/bash
set -euo pipefail

cd /opt/app

./scripts/checkout-etherpad
./scripts/apply-patches

export NODE_ENV=production

cd etherpad-lite

./bin/installDeps.sh

# sqlite is an optional dependency that must be installed seperately. For some
# reason it is also missing this build dependency:
npm install @mapbox/node-pre-gyp
npm install sqlite3
