define [
  'components/Behavior'
  'components/Transform'
  'components/MeshRenderer'
  'lib/Vector3'
  'lib/GMath'
  'lib/Trig'
  'lib/Input'
], (Behavior, Transform, MeshRenderer, Vector3, GMath, Trig, Input) ->
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
      @transform.position = new Vector3 300, 300, 0
      @transform.localScale.Add new Vector3 20, 20, 0
      @renderer.width = 20
      @renderer.height = 20
      @facing = 130
      @flashlightConeAngle = 60
      @flashlightRange = 100

    Start: (engine, cb) ->
      cb()

    SetFacing: (angle) ->
      @facing = GMath.Repeat angle, 360

    Update: (engine) ->
      o = (min, max, interval, time) ->
        GMath.Oscillate (max-min)/2, interval, min, time
      @SetFacing o 0, 360, 15*10, engine.time
      @flashlightConeAngle = GMath.Clamp (Math.abs GMath.Oscillate 80-20, 10, 20, engine.time), 20, 50
      @flashlightRange = GMath.Clamp (Math.abs GMath.Oscillate 500, 45, 50, engine.time), 150, 500

    Draw: (engine) ->
      ctx = engine.canvas.ctx

      # draw my flashlight
      drawFacingAngle ctx, @
      drawFlashlightCone ctx, @
      ctx.save()
      ctx.clip()
      drawPlayerLight ctx, @
      ctx.restore()

    DrawGUI: (engine) ->
      ctx = engine.canvas.ctx
      drawCursor ctx
      engine.Info "θ="+Math.round(@facing), line: 10, size: 14
      engine.Info "cone="+Math.round(@flashlightConeAngle), line: 11, size: 14
      engine.Info "x: #{Math.round Input.mousePosition.x}, y: #{Math.round Input.mousePosition.y}, dX: #{Math.round Input.GetAxisRaw('Mouse X')}, dY: #{Math.round Input.GetAxisRaw('Mouse Y')}", line: 30

  size = 640

  getObjectCoords = (object) ->
    x: object.renderer.vertices[0].x + object.transform.position.x + ( object.renderer.width/2 )
    y: object.renderer.vertices[0].y + object.transform.position.y + ( object.renderer.height/2 )

  drawPlayerLight = (ctx, object) ->
    {x, y} = getObjectCoords object
    # draw player's 360-degree lantern light
    grd=ctx.createRadialGradient(x, y, 10, x, y, object.flashlightRange+10)
    grd.addColorStop(0, 'rgba(255,255,100,.3)')
    grd.addColorStop(1,'rgba(0,0,0,0)')
    ctx.fillStyle=grd
    ctx.fillRect 0, 0, size, size


  angleHypToXY = (A, len) ->
    A = Trig.Deg2Rad A
    o = Math.sin(A) * len
    a = Math.cos(A) * len
    return [o,a]

  drawFacingAngle = (ctx, object) ->
    ctx.lineWidth   = 1
    ctx.strokeStyle = 'yellow'
    {x, y} = getObjectCoords object
    [x2, y2] = angleHypToXY object.facing, object.flashlightRange
    ctx.beginPath()
    ctx.moveTo x, y
    ctx.lineTo x+x2, y+y2
    #ctx.stroke()

  drawFlashlightCone = (ctx, object) ->
    ctx.lineWidth   = 1
    ctx.strokeStyle = 'gray'
    {x, y} = getObjectCoords object

    A = object.facing
    D = object.flashlightConeAngle
    C = A + (D/2)
    B = A - (D/2)

    # draw isosceles triangle representing 2d top-down cone shape of flashlight
    edist = Math.abs object.flashlightRange / Math.cos(Trig.Deg2Rad(D/2)) # outside equilateral distance
    [x2, y2] = angleHypToXY C, edist
    [x3, y3] = angleHypToXY B, edist

    ctx.beginPath()
    ctx.moveTo x, y
    ctx.lineTo x+x2, y+y2
    ctx.lineTo x+x3, y+y3
    ctx.closePath()
    #ctx.stroke()

  drawCursor = (ctx) ->
    ctx.lineWidth   = 1
    ctx.strokeStyle = 'yellow'
    {x,y} = Input.mousePosition
    s = 10

    ctx.beginPath()
    ctx.moveTo x, y
    ctx.lineTo x-s, y
    ctx.moveTo x, y
    ctx.lineTo x+s, y
    ctx.moveTo x, y
    ctx.lineTo x, y-s
    ctx.moveTo x, y
    ctx.lineTo x, y+s
    ctx.stroke()

  return Facing
