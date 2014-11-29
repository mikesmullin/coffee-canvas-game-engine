define [
  '../components/Behavior'
  '../lib/Visibility'
  '../lib/Trig'
], (Behavior, {Block, Wall, Point, EndPoint, Segment, Visibility}, Trig) ->
  class Test extends Behavior
    constructor: ->
      super
      @name = 'Test'

      @v = new Visibility
      @v.new()
      blocks = [
        new Block 120, 120, 50
        new Block 120, 300, 50
      ]
      walls = [
        new Wall new Point(280, 200), new Point(280, 340)
      ]
      @size = 400
      @v.loadMap @size, 10, blocks, walls

    Start: (engine, cb) ->
      cb()

    Update: (engine) ->
      x = 200
      y = 200
      interval = 30
      @x = t(100, interval/2, x, engine.time)
      @y = t(100, interval, y, engine.time)
      @v.setLightLocation @x, @y

      @v.sweep()
      #engine.Log
      #  segments: @v.segments
      #  endpoints: @v.endpoints
      #  open: @v.open
      #  center: @v.center
      #  output: @v.output
      #  demo_intersectionsDetected: @v.demo_intersectionsDetected

    Draw: (engine) ->
      ctx = engine.canvas.ctx
      ctx.lineWidth   = 1
      ctx.strokeStyle = 'rgba(255, 255, 255, .8)'
      ctx.fillStyle   = 'rgba(255, 255, 255, .5)'

      # draw blocks and walls
      for seg in @v.segments
        ctx.beginPath()
        ctx.moveTo seg.p1.x, seg.p1.y
        ctx.lineTo seg.p2.x, seg.p2.y
        ctx.stroke()

      # draw triangles
      # attempt to make sense of v.open array
      interpretSvg = (ctx, path) ->
        i = 0
        while i < path.length
          if path[i] is "M"
            ctx.moveTo path[i + 1], path[i + 2]
            i += 2
          if path[i] is "L"
            ctx.lineTo path[i + 1], path[i + 2]
            i += 2
          i++
        return

      paths = @v.computeVisibleAreaPaths(@v.center, @v.output)

      # apply visible clipping mask
      ctx.save()
      ctx.beginPath()
      interpretSvg(ctx, paths.floor)
      ctx.clip()

      # draw light
      grd=ctx.createRadialGradient(@v.center.x, @v.center.y, 10, @v.center.x, @v.center.y, 300)
      grd.addColorStop(0, 'rgba(255,255,80,1)')
      grd.addColorStop(1,'rgba(0,0,0,0)')
      ctx.fillStyle=grd
      ctx.fillRect 10, 10, @size, @size

      # draw center
      ctx.strokeStyle = 'blue'
      ctx.fillStyle = 'black'
      ctx.strokeWidth = 2
      ctx.beginPath()
      ctx.arc(@v.center.x, @v.center.y, 10, 0, Math.PI*2, true)
      ctx.closePath()
      ctx.fill()

      # draw props
      ctx.fillStyle = 'red'
      ctx.fillRect t(10, .5, 200, engine.time), t(10, 9, 100, engine.time), 20, 20
      ctx.fillStyle = 'rgba(0, 100, 100, .8)'
      ctx.fillRect 100, 300, 20, 20

      ## draw ray cast lines
      #ctx.strokeStyle = "rgba(0, 0, 0, .01)"
      #ctx.lineWidth = 1
      #ctx.beginPath()
      #for angle in @v.getEndpointAngles()
      #  ctx.moveTo @v.center.x, @v.center.y
      #  ctx.lineTo @v.center.x + @size * Math.cos(angle), @v.center.y + @size * Math.sin(angle)
      #  ctx.stroke()

      # lift clipping mask
      ctx.restore()

      ## draw endpoints
      #for p in @v.endpoints when p.visualize
      #  ctx.fillStyle = '#333'
      #  ctx.beginPath()
      #  ctx.arc(p.x, p.y, 3, 0, Math.PI*2, true)
      #  ctx.fill()

      engine.Info "x: #{@x.toFixed(3)}, y:, #{@y.toFixed(3)}           ", 33, 'gray', 12
      engine.Info "WARNING: freezes sometimes. refresh to fix.    ", 33, 'red', 13

      #engine.Stop()

t = (amplitude, period, x0, time) -> amplitude * Math.sin(time * 2 * Math.PI / period) + x0
