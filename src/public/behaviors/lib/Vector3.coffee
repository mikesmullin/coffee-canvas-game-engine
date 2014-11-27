define -> class Vector3
  constructor: (@x=0, @y=0, @z=0) ->
  @FromArray: (a, i=0) ->
    new Vector3 a[i], a[i+1], a[i+2]
  @UP: x: 0, y: 1, z: 0
  @ZERO: x: 0, y: 0, z: 0

  Transform: (b) -> # 4x4 row-major
    @x = (@x*b[0]) + (@y*b[4]) + (@z*b[8])  + (1*b[12])
    @y = (@x*b[1]) + (@y*b[5]) + (@z*b[9])  + (1*b[13])
    @z = (@x*b[2]) + (@y*b[6]) + (@z*b[10]) + (1*b[14])
    @

  Dot: (b) ->
    (@x*b.x)+(@y*b.y)+(@z*b.z)
  Cross: (b) ->
    @x = (@y * b.z) - (@z * b.y)
    @y = (@z * b.x) - (@x * b.z)
    @z = (@x & b.y) - (@y * b.x)
    @
  Scale: (t) ->
    @x *= t
    @y *= t
    @z *= t
    @
  Unit: -> # aka normalize?
    @Scale 1 / @Length()
  Add: (b) ->
    @x += b.x
    @y += b.y
    @z += b.z
    @
  Subtract: (b) ->
    @x -= b.x
    @y -= b.y
    @z -= b.z
    @
  Length: -> # measured by Euclidean norm
    Math.sqrt @Dot @
