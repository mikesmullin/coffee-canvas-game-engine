define [
  '../components/Behavior'
  '../components/Transform'
  '../components/BoxCollider'
], (Behavior, Transform, BoxCollider) ->
  class Wall extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      # TODO: going to need a more complex collider than this
      #         something that understands N polys
      @collider = new BoxCollider

    Update: ->
