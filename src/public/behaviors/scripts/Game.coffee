define [
  'components/Behavior'
  'lib/Collada'
  'lib/Network'
  'objects/Player'
  'objects/Monster'
  'objects/Wall'
  'scripts/CurrentPlayer'
  'scripts/CurrentPlayerPlayer'
  'scripts/CurrentMonsterPlayer'
], (Behavior, Collada, Network, Player, Monster, Wall, CurrentPlayer, CurrentPlayerPlayer, CurrentMonsterPlayer) ->
  class Game extends Behavior
    PreloadData: (engine, cb) ->
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
        inst.renderer.object = inst
        #engine.Log inst
        engine.Bind inst

    EstablishNetwork: (engine, cb) ->
      engine.network = new Network engine: engine
      engine.network.Connect (player_name, player_id) =>
        engine.network.player_id = player_id
        engine.network.player_name = player_name
        for object in engine.objects when object.renderer?.mesh_name is player_name
          if object.constructor.name is 'Player'
            object.BindScript CurrentPlayer
            object.BindScript CurrentPlayerPlayer
          else
            object.BindScript CurrentPlayer
            object.BindScript CurrentMonsterPlayer
        cb()

    Start: (engine, cb) ->
      @PreloadData engine, =>
        @EstablishNetwork engine, =>
          cb()
