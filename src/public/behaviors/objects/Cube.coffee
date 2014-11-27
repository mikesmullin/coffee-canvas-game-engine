define [
  '../components/Behavior'
  '../components/Transform'
  '../components/MeshRenderer'
  '../lib/Vector3'
], (Behavior, Transform, MeshRenderer, Vector3) ->
  class Cube extends Behavior
    constructor: ->
      @name = 'Cube'
      super

    Start: (engine, cb) ->
      @transform = new Transform object: @
      @renderer = new MeshRenderer object: @
      @renderer.materials = [{
        lineWidth:   2
        strokeStyle: 'rgba(255, 0, 0, .8)'
        fillStyle:   'rgba(255, 0, 0, .5)'
      }]
      @renderer.arrayType = 'quads'
      # TODO: make more than one face
      @renderer.vertices = [
        new Vector3 0, 0, 0
        new Vector3 1, 0, 0
        new Vector3 1, 1, 0
        new Vector3 0, 1, 0
      ]

      # position model within game world
      for vec3 in @renderer.vertices
        vec3
          .Transform [ # and zoom to fit canvas
              100, 0,  0,  0
              0,  100, 0,  0
              0,  0,   1,  0
              0,  0,   0,  1
            ]
          .Transform [ # center
              1,   0,   0, 0
              0,   1,   0, 0
              0,   0,   1, 0
              100, 100, 0, 1
            ]

      engine.Log @
      cb()

    Update: (engine) ->
      # TODO: cause these to pulse in a loop over time
      # TODO: demonstrate control over all 3 axis of rotation
      #@transform.position
      #@transform.rotation
      #@transform.scale
