define [
  'lib/Geometry'
], ({Point, Segment}) -> class MeshRenderer
  constructor: ({ @object }) ->
    @enabled = true
    #@castShadows = false
    #@receiveShadows = false
    @vertices = []
    @vcount = []
    @materials = [{}]
    @segments = []
    @mode = 'solid'

  Draw: (engine) ->
    ctx = engine.canvas.ctx
    ctx.lineWidth   = @materials[0].lineWidth or 2
    ctx.strokeStyle = @materials[0].strokeStyle or 'rgba(255, 255, 255, .1)'
    ctx.fillStyle   = @materials[0].fillStyle or 'rgba(255, 255, 255, .5)'

    # apply Transform
    # TODO: stop performing this on every draw
    #        instead do it with Updates to Transform vectors
    wv = [] # world vertices
    for vec3 in @vertices
      wv.push( vec3.Clone()
        #.RotateX @object.transform.rotation.x
        .Scale @object.transform.localScale
        .Add @object.transform.position
        #.RotateY @object.transform.rotation.y
        #.RotateZ @object.transform.rotation.z
        )

    # TODO: move this out into Update and only when the transform changes
    parseSegments = !@segments.length

    offset = 0
    for step in @vcount
      ctx.beginPath()
      x0 = x = wv[@indices[offset]].x
      y0 = y = wv[@indices[offset]].y
      ctx.moveTo x, y
      p1 = new Point x, y if parseSegments
      for i in [offset+2..offset+((step-1)*2)] by 2
        x = wv[@indices[i]].x
        y = wv[@indices[i]].y
        ctx.lineTo x, y
        p2 = new Point x, y if parseSegments
        @segments.push new Segment p1, p2 if parseSegments
        p1 = new Point x, y if parseSegments
      offset = i
      ctx.closePath()
      p2 = new Point x0, y0 if parseSegments
      @segments.push new Segment p1, p2 if parseSegments
      ctx.fill() if @mode is 'solid' or @mode is 'textured'
      ctx.stroke() if @mode is 'wireframe' or @mode is 'textured'
