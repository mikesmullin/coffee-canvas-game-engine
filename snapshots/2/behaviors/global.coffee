requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  'objects/Cube'
  'objects/World'
], (Engine, Cube, World) ->
  engine = new Engine canvas_id: 'main'
  engine.Bind new Cube
  c2 = new Cube
  c2.transform.position.x = 200
  engine.Bind c2
  #engine.Bind new World
  engine.Run()
