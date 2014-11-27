requirejs.config baseUrl: 'behaviors'
require [
  './Engine'
  'objects/World'
], (Engine, World) ->
  Engine.run World
