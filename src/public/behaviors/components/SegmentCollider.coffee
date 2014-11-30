# NOTICE: this becomes exponentially more inefficient with each new segment needing to be checked,
#           but i'm anxious to test something so i'm using it for now...
#
# for now this will also do the job of both collision triggers
#  as well as rigid body 2D physics rejection of transforms that
#  cause a collision
# also does the job of the Character Controller.Move check
#
define [
  'lib/Geometry'
], ({ Point, Segment }) -> class SegmentCollider
  constructor: ({ @object, @is_trigger }) ->
    @enabled = true
    @is_trigger ||= false

  @CollisionFlags:
    None: 0
    Sides: 2
    Above: 4
    Below: 8

  Move: (engine, dest) ->
    # project new segments at dest vec3
    throw 'cant check an object without segments' unless @object.renderer?.segments
    projected_segments =  []
    for seg in @object.renderer.segments
      projected_segments.push new Segment(
        new Point(seg.p1.x + dest.x, seg.p1.y + dest.y),
        new Point(seg.p2.x + dest.x, seg.p2.y + dest.y)
      )

    # check this object's segments against every other object's segments for an intersection
    for obj in engine.objects when obj isnt @object and obj.renderer?.segments?
      for segA in projected_segments
        for segB in obj.renderer.segments
          if @SegmentsCollide(segA.p1.x, segA.p1.y, segA.p2.x, segA.p2.y,
            segB.p1.x, segB.p1.y, segB.p2.x, segB.p2.y)
              if @is_trigger
                engine.TriggerSync 'OnControllerColliderHit', obj
              return SegmentCollider.CollisionFlags.Sides

    # apply move to object.transform.position
    @object.transform.position.x += dest.x
    @object.transform.position.y += dest.y
    # NOTICE: 2D only
    return SegmentCollider.CollisionFlags.None

  # true if segment (a,b)->(c,d) intersects with (p,q)->(r,s)
  SegmentsCollide: (a,b,c,d, p,q,r,s) ->
    det = (c - a) * (s - q) - (r - p) * (d - b)
    return false if det is 0
    lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det
    gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det
    return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1)
