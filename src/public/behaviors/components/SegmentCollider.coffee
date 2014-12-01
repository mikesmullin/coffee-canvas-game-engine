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
    Partial: 1
    Sides: 2
    Above: 4
    Below: 8

  Move: (engine, dest) ->
    # project new segments at dest vec3
    throw 'cant check an object without segments' unless @object.renderer?.segments

    pseg = (segs, d, x=true, y=true) =>
      for s in segs
        new Segment(
          new Point(s.p1.x + (if x then d.x else 0), s.p1.y + (if y then d.y else 0)),
          new Point(s.p2.x + (if x then d.x else 0), s.p2.y + (if y then d.y else 0))
        )
    projected_segments = pseg @object.renderer.segments, dest
    intersect = (ps) =>
      # check this object's segments against every other object's segments for an intersection
      for obj, i in engine.objects when obj isnt @object and obj.renderer?.segments?
        for segA, ii in ps
          for segB, iii in obj.renderer.segments
            if @SegmentsCollide(segA.p1.x, segA.p1.y, segA.p2.x, segA.p2.y,
              segB.p1.x, segB.p1.y, segB.p2.x, segB.p2.y)
                if @is_trigger
                  engine.TriggerObjectSync 'OnControllerColliderHit', @object, obj
                return false if @object.constructor.name is 'Monster' and not @object.visible and obj.constructor.name is 'Player' # monster goes through players
                return false if obj.constructor.name is 'Monster' and not obj.visible and @object.constructor.name is 'Player' # players go through monster
                return true
      return false
    apply_and_notify_network = (xD, yD) =>
      x1 = @object.transform.position.x
      y1 = @object.transform.position.y
      @object.transform.position.x += xD
      @object.transform.position.y += yD
      engine.TriggerObjectSync 'OnControllerMove', @object, x1, y1, x1 + xD, y1 + yD
    if intersect projected_segments
      psX = pseg @object.renderer.segments, dest, true, false
      psY = pseg @object.renderer.segments, dest, false, true
      if not intersect psX # use X
        apply_and_notify_network dest.x, 0
        return SegmentCollider.CollisionFlags.Partial
      else if not intersect psY # use Y
        apply_and_notify_network 0, dest.y
        return SegmentCollider.CollisionFlags.Partial
      else
        return SegmentCollider.CollisionFlags.Sides

    # apply move to object.transform.position
    apply_and_notify_network dest.x, dest.y
    # NOTICE: 2D only
    return SegmentCollider.CollisionFlags.None

  # true if segment (a,b)->(c,d) intersects with (p,q)->(r,s)
  SegmentsCollide: (a,b,c,d, p,q,r,s) ->
    det = (c - a) * (s - q) - (r - p) * (d - b)
    return false if det is 0
    lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det
    gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det
    return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1)
