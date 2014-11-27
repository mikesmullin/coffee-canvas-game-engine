#!/usr/bin/env bash
set -x

DST="../ccge-static${1}"

echo make ${DST} directory...
mkdir -p ${DST}/
echo copy public/ dir...
rsync -avL src/public/* ${DST}/
echo compile coffeescript to javascript...
find $DST -type f -name '*.coffee' | xargs -I'{}' echo coffee -o \$\(dirname {}\) {} | while read line; do eval $line; done
echo copy index.html...
curl localhost:3000 > ${DST}/index.html
echo done.
