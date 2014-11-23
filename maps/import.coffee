xml2js = require 'xml2js'
fs     = require 'fs'
path   = require 'path'
map    = process.argv[2] or '2d-level-editor.dae'
xml    = fs.readFileSync map, encoding: 'utf8'

map = []
xml2js.parseString xml, (err, result) ->
  throw err if err
  for geom in result.COLLADA.library_geometries[0].geometry
    coords = geom.mesh[0].source[0].float_array[0]._
    map.push
      name: geom.$.name
      coords: geom.mesh[0].source[0].float_array[0]._

console.log "var map=#{JSON.stringify map, null, 2};"
