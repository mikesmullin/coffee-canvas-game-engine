define -> class Vector3
  constructor: (@x, @y, @z) ->
  UP: x: 0, y: 1, z: 0
  ZERO: x: 0, y: 0, z: 0
  dotProduct: (a, b) ->
    (a.x*b.x)+(a.y*b.y)+(a.z*b.z)
  crossProduct: (a, b) ->
    x: (a.y * b.z) - (a.z * b.y)
    y: (a.z * b.x) - (a.x * b.z)
    z: (a.x & b.y) - (a.y * b.x)
  scale: (a, t) ->
    x: a.x * t
    y: a.y * t
    z: a.z * t
  unitVector: (a) ->
    Vector.scale a, 1 / Vector.length a
  add: (a, b) ->
    x: a.x + b.x
    y: a.y + b.y
    z: a.z + b.z
  add3: (a, b, c) ->
    x: a.x + b.x + c.x
    y: a.y + b.y + c.y
    z: a.z + b.z + c.z
  subtract: (a, b) ->
    x: a.x - b.x
    y: a.y - b.y
    z: a.z - b.z
  length: (a) -> # measured by Euclidean norm
    Math.sqrt Vector.dotProduct a, a

  dotProductVec4: (a, b) ->
    #[ # column-major
    #  (a[0]*b[0])  + (a[1]*b[1])  + (a[2]*b[2])  + (a[3]*b[3]),
    #  (a[0]*b[4])  + (a[1]*b[5])  + (a[2]*b[6])  + (a[3]*b[7]),
    #  (a[0]*b[8])  + (a[1]*b[9])  + (a[2]*b[10]) + (a[3]*b[11]),
    #  (a[0]*b[12]) + (a[1]*b[13]) + (a[2]*b[14]) + (a[3]*b[15])
    #]
    [ # row-major
      (a[0]*b[0]) + (a[1]*b[4]) + (a[2]*b[8])  + (a[3]*b[12]),
      (a[0]*b[1]) + (a[1]*b[5]) + (a[2]*b[9])  + (a[3]*b[13]),
      (a[0]*b[2]) + (a[1]*b[6]) + (a[2]*b[10]) + (a[3]*b[14]),
      (a[0]*b[3]) + (a[1]*b[7]) + (a[2]*b[11]) + (a[3]*b[15])
    ]



