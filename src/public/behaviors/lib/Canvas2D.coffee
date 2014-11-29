define -> class Canvas2D
  constructor: ({ @id }) ->
    @fps = 45 # TODO: find out why the closer this gets to 60 fps, frames can stack up and fall behind to 10fps
    @canvas = document.getElementById @id
    @ctx = @canvas.getContext '2d'
    @pixelBuf = undefined

  Clear: ->
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height

  DrawPixel: (x, y, r, g, b, a) ->
    index = (x + y * @canvas.width) * 4
    @pixelBuf.data[index + 0] = r
    @pixelBuf.data[index + 1] = g
    @pixelBuf.data[index + 2] = b
    @pixelBuf.data[index + 3] = a

  UpdateCanvas: ->
    @ctx.putImageData @pixelBuf, 0, 0
