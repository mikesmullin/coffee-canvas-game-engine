define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
], (Behavior, Transform, SegmentCollider) ->
  class Monster extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      @collider = new SegmentCollider object: @

    OnTriggerEnter: (collidingObject) ->
