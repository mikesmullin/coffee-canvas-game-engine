define [
  '../components/Behavior'
  '../lib/GlTF'
], (Behavior, GlTF) ->
  class World extends Behavior
    constructor: ->
      @mapRoot = 'models/map1'
      @map = 'map1.gltf'

    startup: (cb) ->
      obj = GlTF.InitMap @mapRoot, @map, ->
        @renderer = new MeshRenderer obj
        cb()

    start: ->

    update: ->

    draw: ->
      GlTF.DrawMap()
