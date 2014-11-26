#!/usr/bin/env bash
set -x

rsync -avL src/public/* ../ccge-static/
rm -rf ../ccge-static/behaviors/*.coffee
rm -rf ../ccge-static/stylesheets/*.styl
echo done. Remember to update index.html
