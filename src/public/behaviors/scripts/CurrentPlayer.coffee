define [
  'components/Script'
  'scripts/TopDownController2D'
  'lib/Input'
  'lib/Visibility'
  'lib/Geometry'
], (Script, TopDownController2D, Input, {Visibility}, {Point, Segment}) ->
  class CurrentPlayer extends Script
    constructor: ->
      super
      @object.BindScript TopDownController2D
      @v = new Visibility

    OnControllerColliderHit: (collidingObject) ->
      console.log "#{@object.constructor.name} would collide with #{collidingObject.constructor.name}"

      #if collidingObject.name is 'Monster'
        #alert 'game over!'
        #location.reload()

    Update: (engine) ->
      @v.ResetSegments()

      # calculate visibility for other players
      for object in getOtherPlayers engine
        @v.AddSegments object.renderer.segments
        @v.SetVantagePoint object.transform.position.x, object.transform.position.y
        @v.Sweep()
        object.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor

      # calculate visibility for current player
      @v.AddSegments @object.renderer.segments
      @v.SetVantagePoint @object.transform.position.x, @object.transform.position.y
      @v.Sweep()
      @object.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor

      #if Input.GetButtonDown 'Use'
        # TODO: toggle flashlight
        # TODO: open doors/drawers
        # TODO: grab keys
        #console.log 'using'

    Draw: (engine) ->
      ctx = engine.canvas.ctx

      # apply visible clipping mask
      traceSvgClippingArea ctx, @object.visibleArea
      console.log @object.visibleArea

      ## apply slight glow to  hallway floors
      #ctx.fillRect 10, 10, @size-20, @size-20

      # trace/draw walls
      object = getWall engine
      ctx.lineWidth   = 1
      ctx.strokeStyle = 'rgba(255, 255, 255, .8)'
      ctx.fillStyle   = 'rgba(255, 255, 255, .1)'
      parse_and_draw_segments ctx, object

      # draw my light
      drawPlayerLight ctx, @object

      # draw other players
      for object in getOtherPlayers engine
        # apply other player's clipping mask
        traceSvgClippingArea ctx, object.visibleArea

        # draw other player's light
        drawPlayerLight ctx, object

        # draw other player
        ctx.beginPath()
        ctx.fillStyle = 'black'
        # TODO: actually draw imported player model. but i need to make it black. also walls need to be made black
        ctx.arc(object.transform.position.x, object.transform.position.y, 10, 0, Math.PI*2, true)
        ctx.fill()

        # lift other player's clipping mask
        ctx.restore()

      # TODO: draw props

      # draw myself
      ctx.fillStyle = 'green'
      ctx.fillRect @object.transform.position.x, @object.transform.position.y, 20, 20

      # lift my clipping mask
      ctx.restore()


getWall = (engine) ->
  for object in engine.objects when object.constructor.name is 'Wall'
    return object

getOtherPlayers = (engine) ->
  players = []
  for object in engine.objects
    if ((object.constructor.name is 'Player' or
      object.constructor.name is 'Monster') and
      object.enabled and
      object isnt @object) # not me
        players.push object
  return players



traceSvgClippingArea = (ctx, path) ->
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

transformed_vertices = (object) ->
  # apply Transform
  # TODO: stop performing this on every draw
  #        instead do it with Updates to Transform vectors
  wv = [] # world vertices
  for vec3 in object.renderer.vertices
    wv.push( vec3.Clone()
      #.RotateX @object.transform.rotation.x
      #.Scale @object.transform.localScale
      .Add object.transform.position
      #.RotateY @object.transform.rotation.y
      #.RotateZ @object.transform.rotation.z
      )
  return wv

parse_and_draw_segments = (ctx, object) ->
  wv = transformed_vertices object

  # TODO: move this out into Update and only when the transform changes
  parseSegments = !object.renderer.segments.length
  return if not parseSegments # we don't care to outline or fill walls anymore

  offset = 0
  indices = object.renderer.indices
  for step in object.renderer.vcount
    ctx.beginPath()
    x0 = x = wv[indices[offset]].x
    y0 = y = wv[indices[offset]].y
    ctx.moveTo x, y
    p1 = new Point x, y if parseSegments
    for i in [offset+2..offset+((step-1)*2)] by 2
      x = wv[indices[i]].x
      y = wv[indices[i]].y
      ctx.lineTo x, y
      p2 = new Point x, y if parseSegments
      object.renderer.segments.push new Segment p1, p2 if parseSegments
      p1 = new Point x, y if parseSegments
    offset = i
    ctx.closePath()
    p2 = new Point x0, y0 if parseSegments
    object.renderer.segments.push new Segment p1, p2 if parseSegments
    #ctx.fill() # we don't care to outline or fill walls anymore
    #ctx.stroke()

size = 640

drawPlayerLight = (ctx, object) ->
  if object.constructor.name is 'Monster'
    # TODO: make monster's vision only visible to monster?
    # monster's 360-degree limited vision
    grd=ctx.createRadialGradient(
      object.transform.position.x,
      object.transform.position.y,
      10,
      object.transform.position.x,
      object.transform.position.y,
      200)
    grd.addColorStop(0, 'rgba(255,255,255,.1)')
    grd.addColorStop(1,'rgba(0,0,0,0)')
    ctx.fillStyle=grd
    ctx.fillRect 0, 0, size, size

  else if object.constructor.name is 'Player'
    # draw player's 360-degree lantern light
    grd=ctx.createRadialGradient(
      object.transform.position.x,
      object.transform.position.y,
      10,
      object.transform.position.x,
      object.transform.position.y,
      300)
    grd.addColorStop(0, 'rgba(255,255,100,.3)')
    grd.addColorStop(1,'rgba(0,0,0,0)')
    ctx.fillStyle=grd
    ctx.fillRect 0, 0, size, size

#t = (amplitude, period, x0, time) -> amplitude * Math.sin(time * 2 * Math.PI / period) + x0
