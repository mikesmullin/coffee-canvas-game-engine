define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
  'scripts/CurrentPlayer'
  'scripts/CurrentPlayerPlayer'
  'scripts/AutoPilot'
], (Behavior, Transform, SegmentCollider, CurrentPlayer, CurrentPlayerPlayer, AutoPilot) ->
  class Player extends Behavior
    constructor: ->
      super
      @flashlightLit = true
      @transform = new Transform object: @
      @collider = new SegmentCollider object: @, is_trigger: true
      @BindScript CurrentPlayer; @BindScript CurrentPlayerPlayer
      #@BindScript AutoPilot
