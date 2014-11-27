define [
  '../components/Behavior'
  '../components/Transform'
  '../components/MeshRenderer'
  '../lib/Vector3'
  '../lib/Time'
], (Behavior, Transform, MeshRenderer, Vector3, Time) ->
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
      @transform.position = new Vector3 100, 100, 0
      @transform.localScale.Add new Vector3 100, 100, 0

      engine.Log @
      cb()

    Update: (engine) ->
      # TODO: cause these to pulse in a loop over time
      # TODO: demonstrate control over all 3 axis of rotation
      # NOTICE: order shouldn't matter here like it did when applying matrix transformations
      #   since the draw will always apply them in a certain [correct?] order
      #@transform.position = new Vector3 100, 100, 0
      #@transform.localScale.Add new Vector3 100, 100, 0
      #@transform.localRotation = new Quaternion 0, 0, 0
      console.log time: engine.time, deltaTime: engine.deltaTime
