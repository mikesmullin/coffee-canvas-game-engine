define -> class Canvas2D
  VideoSettings: class
    @fps: 1 # TODO: find out why mathematically using 60 here lowers it to 10 actual fps

  Video: class
    @canvas: document.getElementById 'mainCanvas'
    @ctx: @canvas.getContext '2d'
    @pixelBuf: undefined
    @drawPixel: (x, y, r, g, b, a) ->
      index = (x + y * @canvas.width) * 4
      @pixelBuf.data[index + 0] = r
      @pixelBuf.data[index + 1] = g
      @pixelBuf.data[index + 2] = b
      @pixelBuf.data[index + 3] = a
    @updateCanvas: ->
      @ctx.putImageData @pixelBuf, 0, 0
  @running: true
