define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
  'scripts/CurrentPlayer'
  'scripts/CurrentMonsterPlayer'
  'scripts/AutoPilot'
], (Behavior, Transform, SegmentCollider, CurrentPlayer, CurrentMonsterPlayer, AutoPilot) ->
  class Monster extends Behavior
    constructor: ->
      super
      @visible = true
      @transform = new Transform object: @
      @collider = new SegmentCollider object: @, is_trigger: true
      #@BindScript CurrentPlayer; @BindScript CurrentMonsterPlayer
      @BindScript AutoPilot
