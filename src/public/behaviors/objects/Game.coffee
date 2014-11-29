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
        # bind mesh to game object
        switch mesh.renderer.mesh_name
          when 'player1' then obj = Player
          when 'player2' then obj = Monster
          when 'wall'    then obj = Wall
          else
            engine.Log "cannot load mesh #{mesh.renderer.mesh_name}: corresponding game object not implemented."
            return
        obj::renderer = mesh.renderer

        # instantiate game object
        inst = new obj
        obj::renderer.object = inst
        engine.Log inst
        engine.Bind inst
