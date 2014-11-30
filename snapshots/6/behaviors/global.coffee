requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  'objects/Game'
], (Engine, Game) ->
  engine = new Engine canvas_id: 'main'
  engine.Bind new Game
  engine.Run()
