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
      @BindScript CurrentPlayer; @BindScript CurrentMonsterPlayer
      #@BindScript AutoPilot

    ToggleVisibility: (force) ->
      return if force? and force is @visible
      if @visible = not @visible
        @renderer.materials[0].fillStyle = 'red'
        console.log 'begin scary monster music.'
      else
        @renderer.materials[0].fillStyle = 'gray'
        console.log 'end scary monster music.'
