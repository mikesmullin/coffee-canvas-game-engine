define [
  '../components/Transform'
  '../components/MeshRenderer'
  '../lib/Vector3'
  '../lib/Trig'
], (Transform, MeshRenderer, Vector3, Trig) ->
  class Collada
    @GetFile: (type, url, cb) ->
      xhr = new XMLHttpRequest()
      xhr.onreadystatechange = ->
        if @readyState is 4 and @status is 200
          cb @response
      xhr.open 'GET', url
      xhr.responseType = type
      xhr.send()

    @LoadModel: (file, done_cb, each_cb) ->
      @GetFile 'application/json', file, (response) =>
        for data in JSON.parse response
          {name, vertices, vcount, indices, fillStyle, transforms} = data

          # push all vertices into a new game object
          obj = {}
          obj.name = name
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
                # TODO: adjust exported model units so
                #         these are no longer necessary
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

          each_cb obj
        done_cb()
