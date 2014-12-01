define [
  'components/Script'
  'scripts/TopDownController2D'
  'lib/Input'
  'lib/Visibility'
  'lib/Geometry'
  'lib/Trig'
  'lib/Time'
], (Script, TopDownController2D, Input, {Visibility}, {Point, Segment}, Trig, Time) ->
  class CurrentPlayer extends Script
    constructor: ->
      super
      @object.BindScript TopDownController2D
      @v = new Visibility
      @won = null

    OnControllerColliderHit: (engine, collidingObject) ->
      console.log "#{@object.constructor.name} would collide with #{collidingObject.constructor.name}"

    OnControllerMove: (engine, x1, y1, x2, y2) ->
      # transmit new position to network
      dX = Math.abs(x2 - x1)
      dY = Math.abs(y2 - y1)
      return if dX is 0 and dY is 0 # inconsequential for network
      engine.network.Send pm: [
        engine.network.player_id,
        x2,
        y2
      ]

    OnEndRound: (engine, winningObject, fromServer=false) ->
      if @object is winningObject
        @won = true
        Time.Delay 4000, -> location.reload()
      else
        @won = false
        Time.Delay 4000, -> location.reload()
      unless fromServer
        @object.engine.network.Send pw: [ @object.engine.network.player_id, winningObject.constructor.name ]

    DrawGUI: (engine) ->
      if @won is true
        engine.Info 'You WON!', color: 'green', line: 10, size: 50
      else if @won is false
        engine.Info 'You LOST!', color: 'red', line: 10, size: 50

    Update: (engine) ->
      @v.ResetSegments()

      object = engine.GetObject 'Wall'
      parse_segments object
      @v.AddSegments object.renderer.segments

      object = engine.GetObject 'Exit'
      parse_segments object

      # calculate visibility for other players
      for object in getOtherPlayers engine, @object
        parse_segments object
        #@v.AddSegments object.renderer.segments
        {x,y} = getObjectCoords object
        @v.SetVantagePoint x, y
        @v.Sweep()
        object.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor

      # calculate visibility for current player
      parse_segments @object
      #@v.AddSegments @object.renderer.segments
      {x,y} = getObjectCoords @object
      @v.SetVantagePoint x, y
      @v.Sweep()
      @object.visibleArea = @v.computeVisibleAreaPaths(@v.center, @v.output).floor


    Draw: (engine) ->
      ctx = engine.canvas.ctx

      # apply visible clipping mask
      traceSvgClippingArea ctx, @object.visibleArea

      ## apply slight glow to hallway floors
      #ctx.fillStyle = 'rgba(255,255,255,0.1)'
      #ctx.fillRect 0, 0, size, size

      # draw walls
      #object = engine.GetObject 'Wall'
      #ctx.lineWidth   = 1
      #ctx.strokeStyle = 'rgba(255, 255, 255, .8)'
      #ctx.fillStyle   = 'rgba(255, 255, 255, .1)'
      #draw_segments ctx, object

      # draw my light
      drawPlayerLight ctx, @object, @object

      # draw myself
      #draw_segments ctx, @object
      draw_vertices ctx, @object

      unless @object.constructor.name is 'Monster' and not @object.visible # monster cant see other players when invisible
        # draw other players
        for object in getOtherPlayers engine, @object
          unless object.constructor.name is 'Monster' and not object.visible # other players cannot see monster when its invisible
            # apply other player's clipping mask
            traceSvgClippingArea ctx, object.visibleArea

            # draw other player's light
            drawPlayerLight ctx, object, @object

            # draw other player
            # TODO: actually draw imported player model. but i need to make it black. also walls need to be made black
            ctx.beginPath()
            ctx.fillStyle = 'black'
            {x,y} = getObjectCoords object
            #ctx.arc(x, y, 10, 0, Math.PI*2, true)
            draw_vertices ctx, object, fillStyle: 'black'
            ctx.fill()

            # lift other player's clipping mask
            ctx.restore()

      # TODO: draw props
      draw_vertices ctx, engine.GetObject 'Exit'

      # lift my clipping mask
      ctx.restore()


  getOtherPlayers = (engine, me) ->
    players = []
    for object in engine.objects
      if ((object.constructor.name is 'Player' or
        object.constructor.name is 'Monster') and
        object.enabled and
        object isnt me)
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

  parse_segments = (object) ->
    wv = transformed_vertices object
    object.renderer.segments = []
    offset = 0
    indices = object.renderer.indices
    for step in object.renderer.vcount
      x0 = x = wv[indices[offset]].x
      y0 = y = wv[indices[offset]].y
      p1 = new Point x, y
      for i in [offset+2..offset+((step-1)*2)] by 2
        x = wv[indices[i]].x
        y = wv[indices[i]].y
        p2 = new Point x, y
        object.renderer.segments.push new Segment p1, p2
        p1 = new Point x, y
      offset = i
      p2 = new Point x0, y0
      object.renderer.segments.push new Segment p1, p2

  draw_segments = (ctx, object) ->
    for seg in object.renderer.segments
      ctx.beginPath()
      ctx.moveTo seg.p1.x, seg.p1.y
      ctx.lineTo seg.p2.x, seg.p2.y
      ctx.stroke()

  draw_vertices = (ctx, object, material_override={}) ->
    ctx.lineWidth   = material_override.lineWidth or object.renderer.materials[0].lineWidth
    ctx.strokeStyle = material_override.strokeStyle or object.renderer.materials[0].strokeStyle
    ctx.fillStyle   = material_override.fillStyle or object.renderer.materials[0].fillStyle
    wv = transformed_vertices object
    offset = 0
    indices = object.renderer.indices
    for step in object.renderer.vcount
      ctx.beginPath()
      x0 = x = wv[indices[offset]].x
      y0 = y = wv[indices[offset]].y
      ctx.moveTo x, y
      for i in [offset+2..offset+((step-1)*2)] by 2
        x = wv[indices[i]].x
        y = wv[indices[i]].y
        ctx.lineTo x, y
      offset = i
      ctx.closePath()
      ctx.fill()

  getObjectCoords = (object) ->
    x: object.renderer.vertices[0].x + object.transform.position.x
    y: object.renderer.vertices[0].y + object.transform.position.y

  size = 640

  drawPlayerLight = (ctx, object, me) ->
    {x, y} = getObjectCoords object
    if object.constructor.name is 'Monster'
      if object is me
        # monster's 360-degree limited vision
        grd=ctx.createRadialGradient(x, y, 10, x, y, 150)
        grd.addColorStop(0, 'rgba(255,255,255,.2)')
        grd.addColorStop(1,'rgba(0,0,0,0)')
        ctx.fillStyle=grd
        ctx.fillRect 0, 0, size, size

    else if object.constructor.name is 'Player'
      if object.flashlightLit
        # draw player's flashlight
        ctx.save()
        drawFlashlightCone ctx, object
        ctx.clip()
        grd=ctx.createRadialGradient(x, y, 10, x, y, 300)
        grd.addColorStop(0, 'rgba(255,255,100,.3)')
        grd.addColorStop(1,'rgba(0,0,0,0)')
        ctx.fillStyle=grd
        ctx.fillRect 0, 0, size, size
        ctx.restore()

      else if object is me
        # 360-degree limited vision
        grd=ctx.createRadialGradient(x, y, 10, x, y, 120)
        grd.addColorStop(0, 'rgba(255,255,255,.2)')
        grd.addColorStop(1,'rgba(0,0,0,0)')
        ctx.fillStyle=grd
        ctx.fillRect 0, 0, size, size
      else
        # monster will see no light from player with flashlight off
        # only their black dot moving against dark gray floor

  angleHypToXY = (A, len) ->
    A = Trig.Deg2Rad A
    o = Math.sin(A) * len
    a = Math.cos(A) * len
    return [o,a]

  drawFlashlightCone = (ctx, object) ->
    {x, y} = getObjectCoords object

    A = object.facing
    D = object.flashlightConeAngle
    C = A + (D/2)
    B = A - (D/2)

    # draw isosceles triangle representing 2d top-down cone shape of flashlight
    edist = Math.abs object.flashlightRange / Math.cos(Trig.Deg2Rad(D/2)) # outside equilateral distance
    [x2, y2] = angleHypToXY C, edist
    [x3, y3] = angleHypToXY B, edist
    ctx.lineWidth = 1
    ctx.strokeStyle = 'white'
    ctx.beginPath()
    ctx.moveTo x, y
    ctx.lineTo x+x2, y+y2
    ctx.lineTo x+x3, y+y3
    ctx.closePath()

  return CurrentPlayer
