requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  #'objects/Cube'
  'objects/World'
  #'objects/Test'
], (Engine, World) ->
  engine = new Engine canvas_id: 'main'
  #engine.Bind new Cube
  engine.Bind new World
  #engine.Bind new Test
  engine.Run()
