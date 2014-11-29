define -> class MeshRenderer
  constructor: ({ @object }) ->
    @enabled = true
    #@castShadows = false
    #@receiveShadows = false
    @arrayType = 'triangles'
    @vertices = []
    @materials = [{}]

  Draw: (engine) ->
    ctx = engine.canvas.ctx
    ctx.lineWidth   = @materials[0].lineWidth or 1
    ctx.strokeStyle = @materials[0].strokeStyle or 'rgba(255, 255, 255, .8)'
    ctx.fillStyle   = @materials[0].fillStyle or 'rgba(255, 255, 255, .5)'

    pos = @object.transform.position

    ## apply Transform
    ## TODO: stop performing this on every draw
    ##        instead do it with Updates to Transform vectors
    #wv = [] # world vertices
    #for vec3 in @vertices
    #  wv.push( vec3.Clone()
    #    .RotateX @object.transform.rotation.x
    #    .Scale @object.transform.localScale
    #    .Add @object.transform.position
    #    #.RotateY @object.transform.rotation.y
    #    #.RotateZ @object.transform.rotation.z
    #    )
    wv = @vertices

    step = switch @arrayType
      when 'triangles' then 3
      when 'quads' then 4

    i=0
    ctx.beginPath()
    ctx.moveTo wv[i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.closePath()
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.closePath()
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.lineTo wv[++i].x, wv[i].y
    ctx.closePath()
    ctx.stroke()

    engine.Stop()
