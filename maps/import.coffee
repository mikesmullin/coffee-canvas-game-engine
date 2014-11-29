#!/usr/bin/env coffee
xml2js = require 'xml2js'
fs     = require 'fs'
path   = require 'path'
map    = process.argv[2]
xml    = fs.readFileSync map, encoding: 'utf8'
as2i   = (a) -> parseFloat v for v in a

objects = []
xml2js.parseString xml, (err, result) ->
  throw err if err

  for geom in result.COLLADA.library_geometries[0].geometry
    coords = geom.mesh[0].source[0].float_array[0]._

    transforms = []
    for node in result.COLLADA.library_visual_scenes[0].visual_scene[0].node when node.$.id is geom.$.name
      transforms.push as2i node.matrix[0]._.split ' '

    fillStyle = null
    for m in result.COLLADA.library_materials[0].material when m.$.id is geom.mesh[0].polylist[0].$.material
      for e in result.COLLADA.library_effects[0].effect when e.$.id is m.instance_effect[0].$.url.substr 1
        rgba = e.profile_COMMON[0].technique[0].phong[0].diffuse[0].color[0]._.split ' '
        fillStyle = "rgba(#{Math.ceil 60+(255*rgba[0])}, #{Math.ceil 30+(255*rgba[1])}, #{Math.ceil 0+(255*rgba[2])}, #{Math.round rgba[3], 1})"

    objects.push
      name: geom.$.name
      vertices: as2i geom.mesh[0].source[0].float_array[0]._.split ' '
      fillStyle: fillStyle
      vcount: as2i geom.mesh[0].polylist[0].vcount[0].replace(/(^\s+|\s+$)/, '').split ' '
      # TODO: provide the texture vs normal map offsets instead of assuming them
      indices: as2i geom.mesh[0].polylist[0].p[0].replace(/(^\s+|\s+$)/, '').split ' '
      transforms: transforms

console.log JSON.stringify objects, null, 2
