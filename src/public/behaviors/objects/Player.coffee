define [
  '../components/Behavior'
  '../components/Transform'
  '../components/BoxCollider'
], (Behavior, Transform, BoxCollider) ->
  class Player extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      @collider = new BoxCollider object: @

    Update: ->
      obj = @
      #if obj.lastX and obj.targetX and obj.lastY and obj.targetY
      #  #rad = getAngle obj.lastX, obj.lastY, obj.targetX, obj.targetY
      #  #deg = rad2deg rad
      #  #console.log name: name, deg: deg

      #  ## rotate player
      #  #rot = [
      #  #  1, 0, 0, 0,
      #  #  0, Math.cos(deg), -1 * Math.sin(deg), 0
      #  #  0, Math.sin(deg), Math.cos(deg), 0
      #  #  0, 0, 0, 1
      #  #]
      #  #for nil, i in obj.vertices
      #  #  obj.vertices[i] = transform rot, obj.vertices[i]

      #obj.lastX = obj.targetX = obj.lastY = obj.targetY = null

    OnTriggerEnter: (collidingObject) ->



