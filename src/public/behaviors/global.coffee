#Engine = require './Engine'
requirejs.config baseUrl: 'behaviors'
require ['./app/World'], (World) ->

#engine = new Engine
#engine.run()
