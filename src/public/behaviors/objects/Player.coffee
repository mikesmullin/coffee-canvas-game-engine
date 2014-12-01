define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
  'scripts/CurrentPlayer'
  'scripts/CurrentPlayerPlayer'
  'scripts/AutoPilot'
  'lib/GMath'
], (Behavior, Transform, SegmentCollider, CurrentPlayer, CurrentPlayerPlayer, AutoPilot, GMath) ->
  class Player extends Behavior
    constructor: ->
      super
      @facing = 0
      @flashlightLit = true
      @flashlightConeAngle = 60
      @flashlightRange = 300
      @transform = new Transform object: @
      @collider = new SegmentCollider object: @, is_trigger: true
      @BindScript CurrentPlayer; @BindScript CurrentPlayerPlayer
      #@BindScript AutoPilot
      @renderer.enabled = false

    ToggleFlashlight: (force) ->
      return if force? and force is @flashlightLit
      if @flashlightLit = not @flashlightLit
        console.log 'click.'
      else
        console.log 'click.'

    SetFacing: (angle) ->
      @facing = GMath.Repeat angle, 360
