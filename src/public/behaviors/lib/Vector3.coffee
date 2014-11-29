define [
  'lib/Trigonometry'
], (Trigonometry) -> class Vector3
  constructor: (@x=0, @y=0, @z=0) ->
  @FromArray: (a, i=0) ->
    new Vector3 a[i], a[i+1], a[i+2]

  @back:    x: 0,  y: 0,  z: -1
  @down:    x: 0,  y: -1, z: 0
  @forward: x: 0,  y: 0,  z: 1
  @left:    x: -1, y: 0,  z: 0
  @one:     x: 1,  y: 1,  z: 1
  @right:   x: 1,  y: 0,  z: 0
  @up:      x: 0,  y: 1,  z: 0
  @zero:    x: 0,  y: 0,  z: 0

  TransformMatrix4: (b) -> # 4x4 column-major
    @x = (@x*b[0]) + (@y*b[1]) + (@z*b[2])  + (1*b[3])
    @y = (@x*b[4]) + (@y*b[5]) + (@z*b[6])  + (1*b[7])
    @z = (@x*b[8]) + (@y*b[9]) + (@z*b[10]) + (1*b[11])
    @

  #TransformMatrix4: (b) -> # 4x4 row-major
  #  @x = (@x*b[0]) + (@y*b[4]) + (@z*b[8])  + (1*b[12])
  #  @y = (@x*b[1]) + (@y*b[5]) + (@z*b[9])  + (1*b[13])
  #  @z = (@x*b[2]) + (@y*b[6]) + (@z*b[10]) + (1*b[14])
  #  @

  # TODO: make Rotate by X, Y, Z in the Transform and apply during draw?
  RotateX: (angle) ->
    nx = (@x * Math.cos(angle)) - (@y * Math.sin(angle))
    ny = (@x * Math.sin(angle)) + (@y * Math.cos(angle))
    @x = nx; @y = ny
    @
  #Rotate: (angle) ->
  # nx = (@x * Math.cos(angle)) - (@y * Math.sin(angle))
  # ny = (@x * Math.sin(angle)) + (@y * Math.cos(angle))
  #  @x = nx; @y = ny
  #  @

  Dot: (b) ->
    (@x*b.x)+(@y*b.y)+(@z*b.z)
  Cross: (b) ->
    @x = (@y * b.z) - (@z * b.y)
    @y = (@z * b.x) - (@x * b.z)
    @z = (@x & b.y) - (@y * b.x)
    @
  Scale: (b) ->
    @x *= b.x
    @y *= b.y
    @z *= b.z
    @
  Unit: -> # aka normalize?
    @Scale @one / @Length()
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
  Copy: (b) ->
    @x = b.x
    @y = b.y
    @z = b.z
    @
  Clone: -> new Vector3 @x, @y, @z
  Length: -> # measured by Euclidean norm
    Math.sqrt @Dot @
