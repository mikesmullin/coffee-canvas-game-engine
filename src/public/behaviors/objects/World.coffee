define [
  '../components/Behavior'
  '../lib/GlTF'
  '../components/Transform'
  '../components/MeshRenderer'
  '../lib/Vector3'
], (Behavior, GlTF, Transform, MeshRenderer, Vector3) ->
  class World extends Behavior
    constructor: ->
      @name = 'World'
      @mapRoot = 'models/map1'
      @map = 'map1.gltf'
      super

    Start: (engine, cb) ->
      GlTF.LoadMap @mapRoot, @map, cb, (name, model_transforms, fill, vertices) =>
        engine.Log name: name, vertices: vertices

        # push all vertices into a new game object
        obj = new Behavior
        obj.name = name # TODO: reconcile with prefabs and objects
        obj.transform = new Transform object: obj
        obj.renderer = new MeshRenderer object: obj
        obj.renderer.materials = [{ color: fill }]

        for nil, i in vertices by 3
          obj.renderer.vertices.push(
            Vector3.FromArray(vertices, i)
              # apply transformations to
              # position model within game world
              # TODO: may want to store these as obj.transform.position, .rotation, etc.
              .Transform model_transforms[1] # local
              .Transform model_transforms[0] # world
              .Transform [ # flip along x-axis
                  1, 0 , 0, 0
                  0, -1, 0, 0
                  0, 0,  1, 0
                  0, 0,  0, 1
                ]
              .Transform [ # and zoom to fit canvas
                  35, 0,  0,  0
                  0,  35, 0,  0
                  0,  0,  35, 0
                  0,  0,  0,  1
                ]
              .Transform [ # center
                  1,   0,   0, 0
                  0,   1,   0, 0
                  0,   0,   1, 0
                  180, 320, 0, 1
                ])

        engine.Bind obj
        engine.Log obj
        cb()
