define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
  'scripts/TopDownController2D'
  'lib/Input'
], (Behavior, Transform, SegmentCollider, TopDownController2D, Input) ->
  class Player extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      @collider = new SegmentCollider object: @
      @BindScript TopDownController2D

    Update: ->
      obj = @

      #if Input.GetButtonDown 'Use'
      #  console.log 'using'

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

    OnControllerColliderHit: (collidingObject) ->
      console.log "#{@constructor.name} would collide with #{collidingObject.constructor.name}"

      #if collidingObject.name is 'Monster'
        #alert 'game over!'
        #location.reload()
