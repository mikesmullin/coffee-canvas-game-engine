define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
  'scripts/CurrentPlayer'
], (Behavior, Transform, SegmentCollider, CurrentPlayer) ->
  class Monster extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      @collider = new SegmentCollider object: @, is_trigger: true
      @BindScript CurrentPlayer
