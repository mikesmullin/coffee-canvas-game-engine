define [
  'components/Behavior'
  'components/Transform'
  'components/SegmentCollider'
], (Behavior, Transform, SegmentCollider) ->
  class Wall extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      # TODO: going to need a more complex collider than this
      #         something that understands N polys
      #@collider = new SegmentCollider

    Update: ->
