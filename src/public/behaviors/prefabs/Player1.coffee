define [
  '../objects/Player'
], (Player) ->
  class Player1 extends Player
    constructor: ->
      @user_id = 1
      @name = 'player1'

    update: ->
