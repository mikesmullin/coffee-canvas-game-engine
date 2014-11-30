define [
  'components/Behavior'
  'components/Transform'
  'components/MeshRenderer'
  'lib/Vector3'
  'lib/GMath'
  'lib/Trigonometry'
], (Behavior, Transform, MeshRenderer, Vector3, GMath, Trigonometry) ->
  class Facing extends Behavior
    constructor: ->
      super
      @transform = new Transform object: @
      @renderer = new MeshRenderer object: @
      @renderer.materials = [{
        lineWidth:   2
        strokeStyle: 'rgba(255, 0, 0, .8)'
        fillStyle:   'rgba(255, 0, 0, .5)'
      }]
      @renderer.arrayType = 'quads'
      # TODO: make more than one face
      @renderer.vertices = [
        new Vector3 0, 0, 0
        new Vector3 1, 0, 0
        new Vector3 1, 1, 0
        new Vector3 0, 1, 0
      ]
      @renderer.vcount = [4]
      @renderer.indices = [0, 0, 1, 0, 2, 0, 3, 0]
      # position model within game world
      @transform.position = new Vector3 100, 100, 0
      @transform.localScale.Add new Vector3 20, 20, 0
      @renderer.width = 20
      @renderer.height = 20
      @facing = 0

    Start: (engine, cb) ->
      cb()

    SetFacing: (angle) ->
      @facing = GMath.Repeat angle, 360

    Update: (engine) ->
      @SetFacing GMath.Oscillate 360/2, 15, 360/2, engine.time
      #@SetFacing @facing+1

    Draw: (engine) ->
      ctx = engine.canvas.ctx

      # draw my light
      drawPlayerLight ctx, @

      drawFacingAngle ctx, @
      engine.Info Math.round(@facing), line: 10, size: 12

  size = 640

  getObjectCoords = (object) ->
    x: object.renderer.vertices[0].x + object.transform.position.x + ( object.renderer.width/2 )
    y: object.renderer.vertices[0].y + object.transform.position.y + ( object.renderer.height/2 )

  drawPlayerLight = (ctx, object) ->
    {x, y} = getObjectCoords object
    # draw player's 360-degree lantern light
    grd=ctx.createRadialGradient(x, y, 10, x, y, 300)
    grd.addColorStop(0, 'rgba(255,255,100,.3)')
    grd.addColorStop(1,'rgba(0,0,0,0)')
    ctx.fillStyle=grd
    ctx.fillRect 0, 0, size, size


  angleSideToXY = (A, len) ->
    A = Trigonometry.Degrees2Radians A
    o = Math.sin(A) * len
    a = Math.cos(A) * len
    return [o,a]

  drawFacingAngle = (ctx, object) ->
    dist = 100
    ctx.lineWidth   = 1
    ctx.strokeStyle = 'yellow'
    {x, y} = getObjectCoords object
    [x2, y2] = angleSideToXY object.facing, dist
    ctx.beginPath()
    ctx.moveTo x, y
    ctx.lineTo x+x2, y+y2
    ctx.stroke()

  return Facing
