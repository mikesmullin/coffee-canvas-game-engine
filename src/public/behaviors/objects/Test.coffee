define [
  '../components/Behavior'
  '../lib/Visibility'
  '../lib/Trig'
], (Behavior, {Block, Wall, Point, EndPoint, Segment, Visibility}, Trig) ->
  class Test extends Behavior
    constructor: ->
      super
      @name = 'Test'

      # generate map
      blocks = [
        new Block 120, 120, 50
        new Block 120, 300, 50
      ]
      walls = [
        new Wall new Point(280, 200), new Point(280, 340)
      ]
      @size = 400
      @v = new Visibility
      @v.loadMap @size, 10, blocks, walls

      @player = new Player
      @monster = new Monster

    Update: (engine) ->
      # player movement
      @player.x = t(100, 30/2, 200, engine.time)
      @player.y = t(100, 30, 200, engine.time)

      # calculate visibility for player
      @v.setVantagePoint @player.x, @player.y
      @v.sweep()
      @player.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor

      # monster movement
      @monster.x = t(10, .5, 25, engine.time)
      @monster.y = t(100, 9, 200, engine.time)

      # calculate visibility for monster
      @v.setVantagePoint @monster.x, @monster.y
      @v.sweep()
      @monster.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor


    Draw: (engine) ->
      ctx = engine.canvas.ctx
      ctx.lineWidth   = 1
      ctx.strokeStyle = 'rgba(255, 255, 255, .8)'
      ctx.fillStyle   = 'rgba(255, 255, 255, .1)'

      ## draw blocks and walls
      #for seg in @v.segments
      #  ctx.beginPath()
      #  ctx.moveTo seg.p1.x, seg.p1.y
      #  ctx.lineTo seg.p2.x, seg.p2.y
      #  ctx.stroke()

      # apply visible clipping mask
      traceSvgClippingArea = (path) ->
        ctx.save()
        ctx.beginPath()
        i = 0
        while i < path.length
          if path[i] is "M"
            ctx.moveTo path[i + 1], path[i + 2]
            i += 2
          if path[i] is "L"
            ctx.lineTo path[i + 1], path[i + 2]
            i += 2
          i++
        ctx.clip()
      traceSvgClippingArea @monster.visibleArea

      ## draw hallway floors
      #ctx.fillRect 10, 10, @size-20, @size-20

      # draw monster's 360-degree limited vision
      grd=ctx.createRadialGradient(@monster.x, @monster.y, 10, @monster.x, @monster.y, 200)
      grd.addColorStop(0, 'rgba(255,255,255,.1)')
      grd.addColorStop(1,'rgba(0,0,0,0)')
      ctx.fillStyle=grd
      ctx.fillRect 10, 10, @size-20, @size-20


      traceSvgClippingArea @player.visibleArea

      # draw player's 360-degree lantern light
      grd=ctx.createRadialGradient(@player.x, @player.y, 10, @player.x, @player.y, 300)
      grd.addColorStop(0, 'rgba(255,255,100,.3)')
      grd.addColorStop(1,'rgba(0,0,0,0)')
      ctx.fillStyle=grd
      ctx.fillRect 10, 10, @size-20, @size-20

      # draw player
      ctx.beginPath()
      ctx.fillStyle = 'black'
      ctx.arc(@player.x, @player.y, 10, 0, Math.PI*2, true)
      ctx.fill()

      # draw props
      ctx.fillStyle = 'rgba(0, 100, 100, .8)'
      ctx.fillRect 100, 300, 20, 20

      # lift player clipping mask
      ctx.restore()

      # draw monster
      ctx.fillStyle = 'red'
      ctx.fillRect @monster.x, @monster.y, 20, 20

      # lift monster clipping mask
      ctx.restore()


t = (amplitude, period, x0, time) -> amplitude * Math.sin(time * 2 * Math.PI / period) + x0

class Player
  constructor: (@x, @y) ->
    @visibleArea = []
class Monster
  constructor: (@x, @y) ->
    @visibleArea = []
