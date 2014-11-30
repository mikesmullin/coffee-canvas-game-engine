define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
  'scripts/CurrentPlayer'
  'scripts/AutoPilot'
], (Behavior, Transform, SegmentCollider, CurrentPlayer, AutoPilot) ->
  class Player extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      @collider = new SegmentCollider object: @, is_trigger: true
      @BindScript CurrentPlayer
      #@BindScript AutoPilot
