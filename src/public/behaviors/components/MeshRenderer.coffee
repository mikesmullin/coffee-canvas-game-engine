define -> class MeshRenderer
  constructor: ->
    @cast_shadows = false
    @receive_shadows = false
    @vertices = []
    @materials = [{
      color: [1,1,1,1] # white
    }]

  Draw: ->
    for name, object of objects
      Video.ctx.lineWidth = 1
      Video.ctx.strokeStyle = 'rgba(255, 255, 255, .15)'

      # draw triangles
      p = object.vertices
      for nil, i in p by 3
        Video.ctx.fillStyle = object.fill
        Video.ctx.beginPath()
        Video.ctx.moveTo p[i].x+object.x, p[i].y+object.y
        Video.ctx.lineTo p[i+1].x+object.x, p[i+1].y+object.y
        Video.ctx.lineTo p[i+2].x+object.x, p[i+2].y+object.y
        Video.ctx.closePath()
        Video.ctx.fill()
        Video.ctx.stroke()
