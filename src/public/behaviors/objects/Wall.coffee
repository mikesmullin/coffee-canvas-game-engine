define [
  '../components/Behavior'
  '../components/BoxCollider'
], (Behavior, BoxCollider) ->
  class Wall extends Behavior
    constructor: ->
      super
      @user_id = null
      @name = null
      # TODO: going to need a more complex collider than this
      #         something that understands N polys
      @collider = new BoxCollider

    Update: ->
