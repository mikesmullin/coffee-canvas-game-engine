requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  'tests/Facing'
], (Engine, Facing) ->
  engine = new Engine canvas_id: 'main'
  engine.Bind new Facing
  engine.Run()
