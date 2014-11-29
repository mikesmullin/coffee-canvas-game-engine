define [
  '../components/Behavior'
  '../components/Transform'
  '../components/MeshRenderer'
  '../lib/Vector3'
  '../lib/Trig'
], (Behavior, Transform, MeshRenderer, Vector3, Trig) ->
  class World extends Behavior
    constructor: ->
      @name = 'World'
      @mapRoot = 'models/map1'
      @map = 'map1.json'
      super

    Start: (engine, cb) ->
      GetFile = (type, url, cb) ->
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = ->
          if @readyState is 4 and @status is 200
            cb @response
        xhr.open 'GET', url
        xhr.responseType = type
        xhr.send()

      GetFile 'application/json', "#{@mapRoot}/#{@map}", (response) => for data in JSON.parse response
        {name, vertices, vcount, indices, fillStyle, transforms} = data

        # push all vertices into a new game object
        obj = new Behavior
        obj.name = name # TODO: reconcile with prefabs and objects
        obj.transform = new Transform object: obj
        obj.renderer = new MeshRenderer object: obj
        obj.renderer.materials = [{
          fillStyle: fillStyle
        }]
        obj.renderer.vcount = vcount
        obj.renderer.indices = indices

        a = Trig.Degrees2Radians 180
        for nil, i in vertices by 3
          obj.renderer.vertices.push(
            Vector3.FromArray(vertices, i)
              # apply transformations to
              # position model within game world
              .TransformMatrix4 transforms[0] # local
              .TransformMatrix4 [ # rotate Z_UP
                  1, 0 , 0, 0
                  0, Math.cos(a), -1 * Math.sin(a), 0
                  0, Math.sin(a),  Math.cos(a), 0
                  0, 0,  0, 1
                ]
              .TransformMatrix4 [ # and zoom to fit canvas
                  35, 0,  0,  0
                  0,  35, 0,  0
                  0,  0,  35, 0
                  0,  0,  0,  1
                ]
              .TransformMatrix4 [ # center
                  1, 0, 0, 180
                  0, 1, 0, 370
                  0, 0, 1, 0
                  0, 0, 0, 1
                ]
            )

        engine.Bind obj
        engine.Log obj
        cb()
