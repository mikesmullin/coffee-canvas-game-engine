define [
  '../components/Behavior'
  '../lib/GlTF'
  '../components/Transform'
], (Behavior, GlTF, Transform) ->
  class World extends Behavior
    constructor: ->
      @name = 'World'
      @mapRoot = 'models/map1'
      @map = 'map1.gltf'
      super

    start: (cb) ->
      GlTF.LoadMap @mapRoot, @map, cb, (name, h, fill_color, vertices) =>
        console.log name: name, vertices: vertices

        # push all vertices into a new game object
        obj = new Behavior
        obj.transform = new Transform
        obj.transform.position
        obj.renderer = new MeshRenderer
        obj.renderer.materials = [{ color: fill_color }]

        h.reverse()
        h.push [ # flip along x-axis
          1, 0, 0, 0
          0, -1, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1
        ]
        h.push [ # and zoom to fit canvas
          35, 0, 0, 0
          0, 35, 0, 0,
          0, 0, 35, 0,
          0, 0, 0, 1
        ]
        h.push [ # center
          1, 0, 0, 0
          0, 1, 0, 0,
          0, 0, 1, 0,
          180, 320, 0, 1
        ]

        for nil, i in vertices by 3
          p = Vector.transform h, {
            x: vertices[i]
            y: vertices[i+1]
            z: vertices[i+2]
          }
          object.renderer.vertices.push p

        @bind object
        console.log object

        cb()
