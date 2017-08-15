#!/usr/bin/env bash
export DISPLAY=:99
xhost +

echo "Running Frame Buffer"
Xvfb :99 -ac &

echo "Running Webdriver manager"
webdriver-manager start

#echo "Running acceptance tests"
#protractor ./tests/conf/docker.conf.js || exit 1;
