requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  'scripts/Game'
], (Engine, Game) ->
  engine = new Engine canvas_id: 'main'
  engine.Bind new Game
  engine.Run()
