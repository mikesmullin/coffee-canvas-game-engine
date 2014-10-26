#!/usr/bin/env bash
set -x

rm -rf .gitignore LICENSE README.md test/ node_modules/ src/public/behaviors/*.coffee src/public/stylesheets/*.styl
mv src/public/* .
rm -rf src/
echo done. Remember to update index.html
