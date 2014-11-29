define [
  'lib/Geometry'
], ({Point, Segment}) ->
  Point: Point
  Segment: Segment
  EndPoint: class EndPoint extends Point
    constructor: ->
      @begin = false
      @segment = null
      @angle = 0.0
      @visualize = false

  ###
  2D visibility algorithm
  Usage: new Visibility()
  Whenever map data changes: LoadSegments()
  Whenever light source changes: SetVantagePoint()
  To calculate the area: Sweep()
  ###

  Visibility: class Visibility
    constructor: ->
      @segments = []
      @endpoints = []
      @center = new Point(0.0, 0.0)

      # These are currently 'open' line segments, sorted so that the nearest
      # segment is first. It's used only during the sweep algorithm, and exposed
      # as a public field here so that the demo can display it.
      @open = []

      # The output is a series of points that forms a visible area polygon
      @output = []

      # For the demo, keep track of wall intersections
      @demo_intersectionsDetected = []

    ResetSegments: ->
      @segments = []
      @endpoints = []

    AddSegments: (segments) ->
      debugger
      console.log segments: segments
      for seg in segments
        @addSegment(seg.p1.x, seg.p1.y, seg.p2.x, seg.p2.y)


    # Add a segment, where the first point shows up in the
    # visualization but the second one does not. (Every endpoint is
    # part of two segments, but we want to only show them once.)
    addSegment: (x1, y1, x2, y2) ->
      segment = null
      p1 = new EndPoint(0.0, 0.0)
      p1.segment = segment
      p1.visualize = true
      p2 = new EndPoint(0.0, 0.0)
      p2.segment = segment
      p2.visualize = false
      segment = new Segment()
      p1.x = x1; p1.y = y1
      p2.x = x2; p2.y = y2
      p1.segment = segment
      p2.segment = segment
      segment.p1 = p1
      segment.p2 = p2
      segment.d = 0.0

      @segments.push(segment)
      @endpoints.push(p1)
      @endpoints.push(p2)


    # Set the light location. Segment and EndPoint data can't be
    # processed until the light location is known.
    SetVantagePoint: (x, y) ->
      @center.x = x
      @center.y = y

      for segment in @segments
        dx = 0.5 * (segment.p1.x + segment.p2.x) - x
        dy = 0.5 * (segment.p1.y + segment.p2.y) - y
        # NOTE: we only use this for comparison so we can use
        # distance squared instead of distance
        segment.d = dx*dx + dy*dy

        # NOTE: future optimization: we could record the quadrant
        # and the y/x or x/y ratio, and sort by (quadrant,
        # ratio), instead of calling atan2. See
        # <https://github.com/mikolalysenko/compare-slope> for a
        # library that does this.
        segment.p1.angle = Math.atan2(segment.p1.y - y, segment.p1.x - x)
        segment.p2.angle = Math.atan2(segment.p2.y - y, segment.p2.x - x)

        dAngle = segment.p2.angle - segment.p1.angle
        if dAngle <= -Math.PI
          dAngle += 2*Math.PI
        if dAngle > Math.PI
          dAngle -= 2*Math.PI
        segment.p1.begin = (dAngle > 0.0)
        segment.p2.begin = !segment.p1.begin


    # Helper: comparison function for sorting points by angle
    _endpoint_compare: (a, b) ->
      # Traverse in angle order
      if a.angle > b.angle
        return 1
      if a.angle < b.angle
        return -1
      # But for ties (common), we want Begin nodes before End nodes
      if !a.begin and b.begin
        return 1
      if a.begin and !b.begin
        return -1
      return 0

    # Helper: leftOf(segment, point) returns true if point is "left"
    # of segment treated as a vector. Note that this assumes a 2D
    # coordinate system in which the Y axis grows downwards, which
    # matches common 2D graphics libraries, but is the opposite of
    # the usual convention from mathematics and in 3D graphics
    # libraries.
    leftOf: (s, p) ->
      # This is based on a 3d cross product, but we don't need to
      # use z coordinate inputs (they're 0), and we only need the
      # sign. If you're annoyed that cross product is only defined
      # in 3d, see "outer product" in Geometric Algebra.
      # <http://en.wikipedia.org/wiki/Geometric_algebra>
      cross = (s.p2.x - s.p1.x) * (p.y - s.p1.y) -
                (s.p2.y - s.p1.y) * (p.x - s.p1.x)
      return cross < 0
      # Also note that this is the naive version of the test and
      # isn't numerically robust. See
      # <https://github.com/mikolalysenko/robust-arithmetic> for a
      # demo of how this fails when a point is very close to the
      # line.

    # Return p*(1-f) + q*f
    interpolate: (p, q, f) ->
      return new Point(p.x*(1-f) + q.x*f, p.y*(1-f) + q.y*f)

    # Helper: do we know that segment a is in front of b?
    # Implementation not anti-symmetric (that is to say,
    # _segment_in_front_of(a, b) != (!_segment_in_front_of(b, a)).
    # Also note that it only has to work in a restricted set of cases
    # in the visibility algorithm; I don't think it handles all
    # cases. See http://www.redblobgames.com/articles/visibility/segment-sorting.html
    _segment_in_front_of: (a, b, relativeTo) ->
      # NOTE: we slightly shorten the segments so that
      # intersections of the endpoints (common) don't count as
      # intersections in this algorithm
      A1 = @leftOf(a, @interpolate(b.p1, b.p2, 0.01))
      A2 = @leftOf(a, @interpolate(b.p2, b.p1, 0.01))
      A3 = @leftOf(a, relativeTo)
      B1 = @leftOf(b, @interpolate(a.p1, a.p2, 0.01))
      B2 = @leftOf(b, @interpolate(a.p2, a.p1, 0.01))
      B3 = @leftOf(b, relativeTo)

      # NOTE: this algorithm is probably worthy of a short article
      # but for now, draw it on paper to see how it works. Consider
      # the line A1-A2. If both B1 and B2 are on one side and
      # relativeTo is on the other side, then A is in between the
      # viewer and B. We can do the same with B1-B2: if A1 and A2
      # are on one side, and relativeTo is on the other side, then
      # B is in between the viewer and A.
      if B1 is B2 and B2 isnt B3
        return true
      if A1 is A2 and A2 is A3
        return true
      if A1 is A2 and A2 isnt A3
        return false
      if B1 is B2 and B2 is B3
        return false

      # If A1 != A2 and B1 != B2 then we have an intersection.
      # Expose it for the GUI to show a message. A more robust
      # implementation would split segments at intersections so
      # that part of the segment is in front and part is behind.
      @demo_intersectionsDetected.push([a.p1, a.p2, b.p1, b.p2])
      return false

      # NOTE: previous implementation was a.d < b.d. That's simpler
      # but trouble when the segments are of dissimilar sizes. If
      # you're on a grid and the segments are similarly sized, then
      # using distance will be a simpler and faster implementation.


    # Run the algorithm, sweeping over all or part of the circle to find
    # the visible area, represented as a set of triangles
    Sweep: (maxAngle=Math.PI) ->
      @output = [] # output set of triangles
      @demo_intersectionsDetected = []
      @endpoints.sort(@_endpoint_compare, true)

      @open = []
      beginAngle = 0.0

      # At the beginning of the sweep we want to know which
      # segments are active. The simplest way to do this is to make
      # a pass collecting the segments, and make another pass to
      # both collect and process them. However it would be more
      # efficient to go through all the segments, figure out which
      # ones intersect the initial sweep line, and then sort them.

      for pass in [0...2]
        for p, c in @endpoints
          #console.log pass: pass, c: c, open: @open
          if pass is 1 and p.angle > maxAngle
            # Early exit for the visualization to show the sweep process
            break

          current_old = if @open.length is 0 then null else @open[0]

          if p.begin
            # Insert into the right place in the list
            i = 0
            node = @open # this may be incorrect. we may be trying to iterate the array inside open
            while node[i] isnt undefined and @_segment_in_front_of(p.segment, node[i], @center)
              i++
            if node[i] is undefined
              @open.push(p.segment)
            else
              @open.splice i, 0, p.segment # insert before node
              i = i+1
          else
            while -1 isnt ii = @open.indexOf p.segment
              @open.splice ii, 1 # remove p.segment from array
              if ii <= i
                i = i-1

          current_new = if @open.length is 0 then null else @open[0]
          if current_old isnt current_new
              if pass is 1
                @addTriangle(beginAngle, p.angle, current_old)
              beginAngle = p.angle

      return

    lineIntersection: (p1, p2, p3, p4) ->
      # From http://paulbourke.net/geometry/lineline2d/
      s = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) /
            ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
      return new Point(p1.x + s * (p2.x - p1.x), p1.y + s * (p2.y - p1.y))


    addTriangle: (angle1, angle2, segment) ->
      p1 = @center
      p2 = new Point(@center.x + Math.cos(angle1), @center.y + Math.sin(angle1))
      p3 = new Point(0.0, 0.0)
      p4 = new Point(0.0, 0.0)

      if segment isnt null
        # Stop the triangle at the intersecting segment
        p3.x = segment.p1.x
        p3.y = segment.p1.y
        p4.x = segment.p2.x
        p4.y = segment.p2.y
      else
        # Stop the triangle at a fixed distance; this probably is
        # not what we want, but it never gets used in the demo
        p3.x = @center.x + Math.cos(angle1) * 500
        p3.y = @center.y + Math.sin(angle1) * 500
        p4.x = @center.x + Math.cos(angle2) * 500
        p4.y = @center.y + Math.sin(angle2) * 500

      pBegin = @lineIntersection(p3, p4, p1, p2)

      p2.x = @center.x + Math.cos(angle2)
      p2.y = @center.y + Math.sin(angle2)
      pEnd = @lineIntersection(p3, p4, p1, p2)

      @output.push(pBegin)
      @output.push(pEnd)

    computeVisibleAreaPaths: (center, output) ->
      path1 = []
      path2 = []
      path3 = []
      i = 0

      while i < output.length
        p1 = output[i]
        p2 = output[i + 1]

        # These are collinear points that Visibility.hx
        # doesn't output properly. The triangle has zero area
        # so we can skip it.
        continue  if isNaN(p1.x) or isNaN(p1.y) or isNaN(p2.x) or isNaN(p2.y)
        path1.push "L", p1.x, p1.y, "L", p2.x, p2.y
        path2.push "M", center.x, center.y, "L", p1.x, p1.y, "M", center.x, center.y, "L", p2.x, p2.y
        path3.push "M", p1.x, p1.y, "L", p2.x, p2.y
        i += 2
      floor: path1
      triangles: path2
      walls: path3

    getEndpointAngles: ->
      angles = []
      for endpoint in @endpoints
        # Since many endpoints are part of more than one line segments
        # there will be duplicates, which we discard here
        if angles.length is 0 or endpoint.angle isnt angles[angles.length - 1]
          angles.push endpoint.angle
      angles
