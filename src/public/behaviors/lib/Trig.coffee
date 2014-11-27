define -> class Trig
  @getAngle: (x1, y1, x2, y2) ->
    distY = Math.abs(y2-y1) # opposite
    distX = Math.abs(x2-x1) # adjacent
    dist  = Math.sqrt((distY*distY)+(distX*distX)) # hypotenuse
    asin  = Math.asin(distY/dist) # return angle in radians
    #console.log x1: x1, y1: y1, x2: x2, y2: y2, distX: distX, distY: distY, dist: dist, asin: asin
    return asin or 0

  @rad2deg: (radians) ->
    return radians*(180/Math.PI)
