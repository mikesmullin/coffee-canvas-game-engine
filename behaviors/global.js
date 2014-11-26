var Behavior, Box, Engine, Time, Transform, Vector, Video, VideoSettings, collidesWith, delay, dotProductVec4, drawMap, getAttrVal, getFile, initMap, loadMap, map, mapRoot, myid, objects, recursivelyFindSceneMeshesWithTransforms, transform, trianglesIntersect, whoami,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Math.rand = function(m, x) {
  return Math.round(Math.random() * (x - m)) + m;
};

delay = function(s, f) {
  return setTimeout(f, s);
};

mapRoot = 'models/map1';

map = 'map1.gltf';

objects = {};

whoami = null;

VideoSettings = (function() {
  function VideoSettings() {}

  VideoSettings.fps = 24;

  return VideoSettings;

})();

Time = (function() {
  function Time() {}

  Time.now = function() {
    return (new Date()).getTime();
  };

  return Time;

})();

Video = (function() {
  function Video() {}

  Video.canvas = document.getElementById('mainCanvas');

  Video.ctx = Video.canvas.getContext('2d');

  Video.pixelBuf = void 0;

  Video.drawPixel = function(x, y, r, g, b, a) {
    var index;
    index = (x + y * this.canvas.width) * 4;
    this.pixelBuf.data[index + 0] = r;
    this.pixelBuf.data[index + 1] = g;
    this.pixelBuf.data[index + 2] = b;
    return this.pixelBuf.data[index + 3] = a;
  };

  Video.updateCanvas = function() {
    return this.ctx.putImageData(this.pixelBuf, 0, 0);
  };

  return Video;

})();

Engine = (function() {
  function Engine() {}

  Engine.running = true;

  Engine.run = function() {
    console.log('Starting at ' + (new Date()));
    return this.startup((function(_this) {
      return function() {
        var drawInterval, framesRendered, maxSkipFrames, maxUpdateLatency, nextUpdate, skippedFrames, tick, updateInterval;
        updateInterval = 1000 / VideoSettings.fps;
        maxUpdateLatency = updateInterval * 1;
        drawInterval = 1000 / VideoSettings.fps;
        skippedFrames = 1;
        maxSkipFrames = 5;
        nextUpdate = Time.now();
        framesRendered = 0;
        setInterval((function() {
          console.log("" + framesRendered + "fps");
          return framesRendered = 0;
        }), 1000);
        tick = function() {
          var next, now, sleepTime;
          next = function() {
            if (_this.running) {
              return requestAnimationFrame(tick);
            }
          };
          now = Time.now();
          if (nextUpdate - maxUpdateLatency > now) {
            nextUpdate = now;
          }
          if (now >= nextUpdate) {
            nextUpdate += updateInterval;
            _this.update();
            if (now > nextUpdate && skippedFrames < maxSkipFrames) {
              skippedFrames++;
            } else {
              _this.draw();
              framesRendered++;
              skippedFrames = 0;
            }
          } else {
            sleepTime = nextUpdate - now;
            if (sleepTime > 0) {
              return delay(sleepTime, next);
            }
          }
          return next();
        };
        return tick();
      };
    })(this));
  };

  Engine.stop = function() {};

  Engine.startup = function(cb) {
    var startX, startY, step;
    step = 10;
    document.addEventListener('mousedown', (function(e) {
      var focused;
      return focused = e.target === Video.canvas;
    }), true);
    document.addEventListener('keydown', (function(e) {
      var _ref, _ref1, _ref2, _ref3;
      switch (e.keyCode) {
        case 87:
          return (_ref = objects[whoami]) != null ? _ref.yT -= step : void 0;
        case 65:
          return (_ref1 = objects[whoami]) != null ? _ref1.xT -= step : void 0;
        case 83:
          return (_ref2 = objects[whoami]) != null ? _ref2.yT += step : void 0;
        case 68:
          return (_ref3 = objects[whoami]) != null ? _ref3.xT += step : void 0;
      }
    }), true);
    startX = startY = 0;
    Video.canvas.addEventListener('touchstart', function(e) {
      startX = e.touches[0].pageX;
      startY = e.touches[0].pageY;
      return e.preventDefault();
    });
    Video.canvas.addEventListener('touchend', function(e) {
      var distance, endX, endY, _ref, _ref1, _ref2, _ref3;
      endX = e.changedTouches[0].pageX;
      endY = e.changedTouches[0].pageY;
      distance = Math.sqrt(Math.pow(startX - endX, 2) + Math.pow(startY - endY, 2));
      if (endX < startX) {
        if ((_ref = objects[whoami]) != null) {
          _ref.xT -= step;
        }
      } else {
        if ((_ref1 = objects[whoami]) != null) {
          _ref1.xT += step;
        }
      }
      if (endY < startY) {
        return (_ref2 = objects[whoami]) != null ? _ref2.yT -= step : void 0;
      } else {
        return (_ref3 = objects[whoami]) != null ? _ref3.yT += step : void 0;
      }
    });
    return initMap(map, cb);
  };

  Engine.shutdown = function() {};

  Engine.update = function() {
    var name, obj, _i, _len, _ref, _results;
    _ref = ['player1', 'player2'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      obj = objects[name];
      if (obj.xT || obj.yT) {
        if (collidesWith(obj, objects['wall'])) {
          console.log('collide');
        } else if (collidesWith(obj, objects[whoami === 'player1' ? 'player2' : 'player1'])) {
          console.log('collide');
        } else {
          obj.x += obj.xT;
          obj.y += obj.yT;
        }
        _results.push(obj.xT = obj.yT = obj.zT = 0);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Engine.draw = function() {
    Video.ctx.clearRect(0, 0, Video.canvas.width, Video.canvas.height);
    return drawMap();
  };

  return Engine;

})();

collidesWith = function(a, b) {
  var aT, bT, i, ii, nil, _i, _j, _len, _len1, _ref, _ref1;
  _ref = a.vertices;
  for (i = _i = 0, _len = _ref.length; _i < _len; i = _i += 3) {
    nil = _ref[i];
    aT = [
      {
        x: a.vertices[i].x + a.x + a.xT,
        y: a.vertices[i].y + a.y + a.yT
      }, {
        x: a.vertices[i + 1].x + a.x + a.xT,
        y: a.vertices[i + 1].y + a.y + a.yT
      }, {
        x: a.vertices[i + 2].x + a.x + a.xT,
        y: a.vertices[i + 2].y + a.y + a.yT
      }
    ];
    _ref1 = b.vertices;
    for (ii = _j = 0, _len1 = _ref1.length; _j < _len1; ii = _j += 3) {
      nil = _ref1[ii];
      bT = [
        {
          x: b.vertices[ii].x + b.y,
          y: b.vertices[ii].y + b.y
        }, {
          x: b.vertices[ii + 1].x + b.x,
          y: b.vertices[ii + 1].y + b.y
        }, {
          x: b.vertices[ii + 2].x + b.x,
          y: b.vertices[ii + 2].y + b.y
        }
      ];
      if (trianglesIntersect(aT, bT)) {
        return true;
      }
    }
  }
  return false;
};

trianglesIntersect = function(a, b) {
  var l1x, l1y, l2x, l2y, r1x, r1y, r2x, r2y;
  l1x = Math.min(a[0].x, a[1].x, a[2].x);
  r1x = Math.max(a[0].x, a[1].x, a[2].x);
  l1y = Math.max(a[0].y, a[1].y, a[2].y);
  r1y = Math.min(a[0].y, a[1].y, a[2].y);
  l2x = Math.min(b[0].x, b[1].x, b[2].x);
  r2x = Math.max(b[0].x, b[1].x, b[2].x);
  l2y = Math.max(b[0].y, b[1].y, b[2].y);
  r2y = Math.min(b[0].y, b[1].y, b[2].y);
  if (l1x > r2x || l2x > r1x) {
    return false;
  }
  if (l1y < r2y || l2y < r1y) {
    return false;
  }
  return true;
};

Vector = {
  UP: {
    x: 0,
    y: 1,
    z: 0
  },
  ZERO: {
    x: 0,
    y: 0,
    z: 0
  },
  dotProduct: function(a, b) {
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
  },
  crossProduct: function(a, b) {
    return {
      x: (a.y * b.z) - (a.z * b.y),
      y: (a.z * b.x) - (a.x * b.z),
      z: (a.x & b.y) - (a.y * b.x)
    };
  },
  scale: function(a, t) {
    return {
      x: a.x * t,
      y: a.y * t,
      z: a.z * t
    };
  },
  unitVector: function(a) {
    return Vector.scale(a, 1 / Vector.length(a));
  },
  add: function(a, b) {
    return {
      x: a.x + b.x,
      y: a.y + b.y,
      z: a.z + b.z
    };
  },
  add3: function(a, b, c) {
    return {
      x: a.x + b.x + c.x,
      y: a.y + b.y + c.y,
      z: a.z + b.z + c.z
    };
  },
  subtract: function(a, b) {
    return {
      x: a.x - b.x,
      y: a.y - b.y,
      z: a.z - b.z
    };
  },
  length: function(a) {
    return Math.sqrt(Vector.dotProduct(a, a));
  }
};

dotProductVec4 = function(a, b) {
  return [(a[0] * b[0]) + (a[1] * b[4]) + (a[2] * b[8]) + (a[3] * b[12]), (a[0] * b[1]) + (a[1] * b[5]) + (a[2] * b[9]) + (a[3] * b[13]), (a[0] * b[2]) + (a[1] * b[6]) + (a[2] * b[10]) + (a[3] * b[14]), (a[0] * b[3]) + (a[1] * b[7]) + (a[2] * b[11]) + (a[3] * b[15])];
};

Transform = (function() {
  function Transform() {}

  Transform.prototype.translate = function(translation) {};

  return Transform;

})();

Behavior = (function() {
  function Behavior() {}

  Behavior.prototype.transform = new Transform();

  return Behavior;

})();

Box = (function(_super) {
  __extends(Box, _super);

  function Box() {
    return Box.__super__.constructor.apply(this, arguments);
  }

  Box.prototype.update = function() {
    return transform.translate;
  };

  Box.prototype.draw = function() {
    return Video.drawPixel(Math.rand(0, Video.canvas.width), Math.rand(0, Video.canvas.height), 255, 0, 0, 255);
  };

  return Box;

})(Behavior);

getFile = function(type, url, cb) {
  var xhr;
  xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (this.readyState === 4 && this.status === 200) {
      return cb(this.response);
    }
  };
  xhr.open('GET', url);
  xhr.responseType = type;
  return xhr.send();
};

getAttrVal = function(data, accessor_id, cb) {
  var a, accessor, b, buffer, bufferView;
  accessor = data.accessors[accessor_id];
  bufferView = data.bufferViews[accessor.bufferView];
  buffer = data.buffers[bufferView.buffer];
  a = function(next) {
    if (buffer.data) {
      return next();
    }
    return getFile('blob', "" + mapRoot + "/" + buffer.uri, function(bin) {
      var reader;
      if (buffer.type === 'arraybuffer') {
        reader = new FileReader;
        reader.addEventListener('loadend', function() {
          buffer.data = reader.result;
          return next();
        });
        return reader.readAsArrayBuffer(bin);
      }
    });
  };
  b = function() {
    var attrSlice, viewSlice;
    viewSlice = buffer.data.slice(bufferView.byteOffset, bufferView.byteOffset + bufferView.byteLength);
    attrSlice = viewSlice.slice(accessor.byteOffset, accessor.byteOffset + (accessor.byteStride * accessor.count));
    switch (accessor.type) {
      case 'VEC3':
        return cb(new Float32Array(attrSlice));
    }
  };
  return a(b);
};

recursivelyFindSceneMeshesWithTransforms = function(data) {};

loadMap = function(map, done_cb, cb) {
  return getFile('application/json', map, function(response) {
    var child, color, data, flow, id, matrixHierarchy, node, rgba, _fn, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
    data = JSON.parse(response);
    flow = new async;
    matrixHierarchy = [];
    _ref = data.scenes[data.scene].nodes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      matrixHierarchy.push(data.nodes[node].matrix);
      _ref1 = data.nodes[node].children;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        child = _ref1[_j];
        matrixHierarchy.push(data.nodes[child].matrix);
        _ref2 = data.nodes[child].meshes;
        _fn = function(id, h, color) {
          return flow.serial(function(next) {
            return getAttrVal(data, data.meshes[id].primitives[0].attributes.POSITION, function(vertices) {
              cb(data.meshes[id].name, h, color, vertices);
              return next();
            });
          });
        };
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          id = _ref2[_k];
          color = '';
          rgba = (_ref3 = data.materials[data.meshes[id].primitives[0].material].instanceTechnique.values) != null ? _ref3.diffuse : void 0;
          color = "rgba(" + (Math.ceil(60 + (255 * rgba[0]))) + ", " + (Math.ceil(30 + (255 * rgba[1]))) + ", " + (Math.ceil(0 + (255 * rgba[2]))) + ", " + (Math.round(rgba[3], 1)) + ")";
          _fn(id, matrixHierarchy.slice(0), color);
        }
        matrixHierarchy.pop();
      }
    }
    return flow.go(function(err) {
      return done_cb();
    });
  });
};

initMap = function(map, cb) {
  return loadMap("" + mapRoot + "/" + map, cb, function(name, h, fill_color, vertices) {
    var i, local, nil, object, p, world, xmax, xmin, ymax, ymin, zmax, zmin, _i, _len;
    object = {
      name: name,
      vertices: [],
      fill: fill_color,
      x: null,
      y: null,
      z: null,
      xT: 0,
      yT: 0,
      zT: 0,
      width: null,
      height: null,
      depth: null,
      min: [null, null, null],
      max: [null, null, null]
    };
    world = h[0], local = h[1];
    h = [local, world, [1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], [40, 0, 0, 0, 0, 40, 0, 0, 0, 0, 40, 0, 0, 0, 0, 1], [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 170, 270, 0, 1]];
    xmin = ymin = zmin = xmax = ymax = zmax = null;
    for (i = _i = 0, _len = vertices.length; _i < _len; i = _i += 3) {
      nil = vertices[i];
      p = transform(h, {
        x: vertices[i],
        y: vertices[i + 1],
        z: vertices[i + 2]
      });
      xmin = Math.min(p.x, null === xmin ? p.x : xmin);
      ymin = Math.min(p.y, null === ymin ? p.y : ymin);
      zmin = Math.min(p.z, null === zmin ? p.z : zmin);
      xmax = Math.max(p.x, null === xmax ? p.x : xmax);
      ymax = Math.max(p.y, null === ymax ? p.y : ymax);
      zmax = Math.max(p.z, null === zmax ? p.z : zmax);
      object.vertices.push(p);
    }
    object.min = [xmin, ymin, zmin];
    object.max = [xmax, ymax, zmax];
    object.width = xmax - xmin;
    object.height = ymax - ymin;
    object.depth = zmax - zmin;
    object.x = 0;
    object.y = 0;
    object.z = 0;
    objects[name] = object;
    return console.log(object);
  });
};

transform = function(h, p) {
  var matrix, _i, _len, _ref;
  for (_i = 0, _len = h.length; _i < _len; _i++) {
    matrix = h[_i];
    _ref = dotProductVec4([p.x, p.y, p.z, 1], matrix), p.x = _ref[0], p.y = _ref[1], p.z = _ref[2];
  }
  return p;
};

drawMap = function() {
  var i, name, nil, object, p, _results;
  _results = [];
  for (name in objects) {
    object = objects[name];
    Video.ctx.lineWidth = 1;
    Video.ctx.strokeStyle = 'rgba(255, 255, 255, .15)';
    p = object.vertices;
    _results.push((function() {
      var _i, _len, _results1;
      _results1 = [];
      for (i = _i = 0, _len = p.length; _i < _len; i = _i += 3) {
        nil = p[i];
        Video.ctx.fillStyle = object.fill;
        Video.ctx.beginPath();
        Video.ctx.moveTo(p[i].x + object.x, p[i].y + object.y);
        Video.ctx.lineTo(p[i + 1].x + object.x, p[i + 1].y + object.y);
        Video.ctx.lineTo(p[i + 2].x + object.x, p[i + 2].y + object.y);
        Video.ctx.closePath();
        Video.ctx.fill();
        _results1.push(Video.ctx.stroke());
      }
      return _results1;
    })());
  }
  return _results;
};

Engine.run();

myid = 1;

whoami = 'player1';
