define [
  '../components/Behavior'
  '../lib/Collada'
  '../objects/Player'
  '../objects/Monster'
  '../objects/Wall'
], (Behavior, Collada, Player, Monster, Wall) ->
  class Game extends Behavior
    Start: (engine, cb) ->
      Collada.LoadModel 'models/map1/map1.json', cb, (mesh) ->
        switch mesh.name
          when 'player1'
            obj = new Player
          when 'player2'
            obj = new Monster
          when 'wall'
            obj = new Wall
          else
            engine.Log "unexpected mesh #{mesh.name} loaded. skipping..."
            return

        obj.name = mesh.name
        obj.transform = mesh.transform
        obj.renderer = mesh.renderer

        engine.Log obj
        engine.Bind obj
