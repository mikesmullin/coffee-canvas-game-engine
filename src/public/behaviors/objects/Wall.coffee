define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
], (Behavior, Transform, SegmentCollider) ->
  class Wall extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      #@collider = new SegmentCollider
      @renderer.enabled = false

    Start: ->

    Update: ->

