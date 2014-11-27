requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  'objects/Cube'
  'objects/World'
], (Engine, Cube, World) ->
  engine = new Engine canvas_id: 'main'
  engine.Bind new Cube
  #engine.Bind new World
  engine.Run()
