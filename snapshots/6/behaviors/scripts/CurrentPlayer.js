// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['components/Script', 'scripts/TopDownController2D', 'lib/Input', 'lib/Visibility', 'lib/Geometry'], function(Script, TopDownController2D, Input, _arg, _arg1) {
    var CurrentPlayer, Point, Segment, Visibility, drawPlayerLight, draw_segments, draw_vertices, getObjectCoords, getOtherPlayers, getWall, parse_segments, size, traceSvgClippingArea, transformed_vertices;
    Visibility = _arg.Visibility;
    Point = _arg1.Point, Segment = _arg1.Segment;
    CurrentPlayer = (function(_super) {
      __extends(CurrentPlayer, _super);

      function CurrentPlayer() {
        CurrentPlayer.__super__.constructor.apply(this, arguments);
        this.object.BindScript(TopDownController2D);
        this.v = new Visibility;
      }

      CurrentPlayer.prototype.OnControllerColliderHit = function(engine, collidingObject) {
        return console.log("" + this.object.constructor.name + " would collide with " + collidingObject.constructor.name);
      };

      CurrentPlayer.prototype.Update = function(engine) {
        var object, x, y, _i, _len, _ref, _ref1, _ref2;
        this.v.ResetSegments();
        object = getWall(engine);
        parse_segments(object);
        this.v.AddSegments(object.renderer.segments);
        _ref = getOtherPlayers(engine, this.object);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          object = _ref[_i];
          parse_segments(object);
          _ref1 = getObjectCoords(object), x = _ref1.x, y = _ref1.y;
          this.v.SetVantagePoint(x, y);
          this.v.Sweep();
          object.visibleArea = this.v.computeVisibleAreaPaths(this.v.center, this.v.output).floor;
        }
        parse_segments(this.object);
        _ref2 = getObjectCoords(this.object), x = _ref2.x, y = _ref2.y;
        this.v.SetVantagePoint(x, y);
        this.v.Sweep();
        return this.object.visibleArea = this.v.computeVisibleAreaPaths(this.v.center, this.v.output).floor;
      };

      CurrentPlayer.prototype.Draw = function(engine) {
        var ctx, object, x, y, _i, _len, _ref, _ref1;
        ctx = engine.canvas.ctx;
        traceSvgClippingArea(ctx, this.object.visibleArea);
        drawPlayerLight(ctx, this.object, this.object);
        draw_vertices(ctx, this.object);
        if (!(this.object.constructor.name === 'Monster' && !this.object.visible)) {
          _ref = getOtherPlayers(engine, this.object);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            object = _ref[_i];
            if (!(object.constructor.name === 'Monster' && !object.visible)) {
              traceSvgClippingArea(ctx, object.visibleArea);
              drawPlayerLight(ctx, object, this.object);
              ctx.beginPath();
              ctx.fillStyle = 'black';
              _ref1 = getObjectCoords(object), x = _ref1.x, y = _ref1.y;
              ctx.arc(x, y, 10, 0, Math.PI * 2, true);
              ctx.fill();
              ctx.restore();
            }
          }
        }
        return ctx.restore();
      };

      return CurrentPlayer;

    })(Script);
    getWall = function(engine) {
      var object, _i, _len, _ref;
      _ref = engine.objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if (object.constructor.name === 'Wall') {
          return object;
        }
      }
    };
    getOtherPlayers = function(engine, me) {
      var object, players, _i, _len, _ref;
      players = [];
      _ref = engine.objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if ((object.constructor.name === 'Player' || object.constructor.name === 'Monster') && object.enabled && object !== me) {
          players.push(object);
        }
      }
      return players;
    };
    traceSvgClippingArea = function(ctx, path) {
      var i;
      ctx.save();
      ctx.beginPath();
      i = 0;
      while (i < path.length) {
        if (path[i] === "M") {
          ctx.moveTo(path[i + 1], path[i + 2]);
          i += 2;
        }
        if (path[i] === "L") {
          ctx.lineTo(path[i + 1], path[i + 2]);
          i += 2;
        }
        i++;
      }
      return ctx.clip();
    };
    transformed_vertices = function(object) {
      var vec3, wv, _i, _len, _ref;
      wv = [];
      _ref = object.renderer.vertices;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        vec3 = _ref[_i];
        wv.push(vec3.Clone().Add(object.transform.position));
      }
      return wv;
    };
    parse_segments = function(object) {
      var i, indices, offset, p1, p2, step, wv, x, x0, y, y0, _i, _j, _len, _ref, _ref1, _ref2, _results;
      wv = transformed_vertices(object);
      object.renderer.segments = [];
      offset = 0;
      indices = object.renderer.indices;
      _ref = object.renderer.vcount;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        step = _ref[_i];
        x0 = x = wv[indices[offset]].x;
        y0 = y = wv[indices[offset]].y;
        p1 = new Point(x, y);
        for (i = _j = _ref1 = offset + 2, _ref2 = offset + ((step - 1) * 2); _j <= _ref2; i = _j += 2) {
          x = wv[indices[i]].x;
          y = wv[indices[i]].y;
          p2 = new Point(x, y);
          object.renderer.segments.push(new Segment(p1, p2));
          p1 = new Point(x, y);
        }
        offset = i;
        p2 = new Point(x0, y0);
        _results.push(object.renderer.segments.push(new Segment(p1, p2)));
      }
      return _results;
    };
    draw_segments = function(ctx, object) {
      var seg, _i, _len, _ref, _results;
      _ref = object.renderer.segments;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        seg = _ref[_i];
        ctx.beginPath();
        ctx.moveTo(seg.p1.x, seg.p1.y);
        ctx.lineTo(seg.p2.x, seg.p2.y);
        _results.push(ctx.stroke());
      }
      return _results;
    };
    draw_vertices = function(ctx, object) {
      var i, indices, offset, step, wv, x, x0, y, y0, _i, _j, _len, _ref, _ref1, _ref2, _results;
      ctx.lineWidth = object.renderer.materials[0].lineWidth;
      ctx.strokeStyle = object.renderer.materials[0].strokeStyle;
      ctx.fillStyle = object.renderer.materials[0].fillStyle;
      wv = transformed_vertices(object);
      offset = 0;
      indices = object.renderer.indices;
      _ref = object.renderer.vcount;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        step = _ref[_i];
        ctx.beginPath();
        x0 = x = wv[indices[offset]].x;
        y0 = y = wv[indices[offset]].y;
        ctx.moveTo(x, y);
        for (i = _j = _ref1 = offset + 2, _ref2 = offset + ((step - 1) * 2); _j <= _ref2; i = _j += 2) {
          x = wv[indices[i]].x;
          y = wv[indices[i]].y;
          ctx.lineTo(x, y);
        }
        offset = i;
        ctx.closePath();
        _results.push(ctx.fill());
      }
      return _results;
    };
    getObjectCoords = function(object) {
      return {
        x: object.renderer.vertices[0].x + object.transform.position.x,
        y: object.renderer.vertices[0].y + object.transform.position.y
      };
    };
    size = 640;
    drawPlayerLight = function(ctx, object, me) {
      var grd, x, y, _ref;
      _ref = getObjectCoords(object), x = _ref.x, y = _ref.y;
      if (object.constructor.name === 'Monster') {
        if (object === me) {
          grd = ctx.createRadialGradient(x, y, 10, x, y, 200);
          grd.addColorStop(0, 'rgba(255,255,255,.1)');
          grd.addColorStop(1, 'rgba(0,0,0,0)');
          ctx.fillStyle = grd;
          return ctx.fillRect(0, 0, size, size);
        }
      } else if (object.constructor.name === 'Player') {
        if (object.flashlightLit) {
          grd = ctx.createRadialGradient(x, y, 10, x, y, 300);
          grd.addColorStop(0, 'rgba(255,255,100,.3)');
          grd.addColorStop(1, 'rgba(0,0,0,0)');
          ctx.fillStyle = grd;
          return ctx.fillRect(0, 0, size, size);
        } else if (object === me) {
          grd = ctx.createRadialGradient(x, y, 10, x, y, 200);
          grd.addColorStop(0, 'rgba(255,255,255,.1)');
          grd.addColorStop(1, 'rgba(0,0,0,0)');
          ctx.fillStyle = grd;
          return ctx.fillRect(0, 0, size, size);
        } else {

        }
      }
    };
    return CurrentPlayer;
  });

}).call(this);
