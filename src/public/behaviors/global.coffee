requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  'objects/World'
], (Engine, World) ->
  engine = new Engine canvas_id: 'main'
  engine.bind new World
  engine.run()
