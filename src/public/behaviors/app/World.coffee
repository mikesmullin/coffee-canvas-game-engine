define [
  '../components/Behavior'
  '../lib/GlTF'
], (Behavior, GlTF) ->
  class World extends Behavior
    constructor: ->
      @mapRoot = 'models/map1'
      @map = 'map1.gltf'

    startup: ->
      obj = GlTF.InitMap @mapRoot, @map
      @renderer = new MeshRenderer obj

    start: ->

    update: ->
