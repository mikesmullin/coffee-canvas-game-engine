define [
  '../components/Behavior'
], (Behavior) ->
  class Player extends Behavior
    constructor: ->
      @user_id = null
      @name = null
    update: ->
