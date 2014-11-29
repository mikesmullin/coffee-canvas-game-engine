define [
  '../components/Behavior'
  '../components/BoxCollider'
], (Behavior, BoxCollider) ->
  class Monster extends Behavior
    constructor: ->
      super
      @user_id = null
      @name = null
      @collider = new BoxCollider

    Update: ->
