#!/bin/bash

# wait for dbserver to come up
while ! nc -z mongodb 27017 ; do
    sleep 10;
    echo "mongodb not up yet...."
done

# setup database
echo "create database"
mongo file.js --username root --password root

# upgrade schema to latest version
echo "update playground database"
pushd ./database
    db-migrate-mongodb up
popd

# run debugger
node-inspector --no-preload --web-port=8080 --save-live-edit=true --hidden=node_modules &

# install npm modules
cd /srv
npm install

# start website process
forever -a --uid="playground" -c "node --debug=4001" /srv/server.js &

# dont let container end
echo "run container"
while true; do sleep 10000; done
