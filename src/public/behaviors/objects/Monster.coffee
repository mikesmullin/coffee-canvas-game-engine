define [
  '../components/Behavior'
  '../components/Transform'
  '../components/BoxCollider'
], (Behavior, Transform, BoxCollider) ->
  class Monster extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      @collider = new BoxCollider object: @

    OnTriggerEnter: (collidingObject) ->
