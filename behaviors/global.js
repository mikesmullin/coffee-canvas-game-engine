var Behavior, Box, Engine, Time, Transform, Vector3, Video, VideoSettings, delay,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Math.rand = function(m, x) {
  return Math.round(Math.random() * (x - m)) + m;
};

delay = function(s, f) {
  return setTimeout(f, s);
};

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
    var drawInterval, framesRendered, maxSkipFrames, maxUpdateLatency, nextUpdate, skippedFrames, tick, updateInterval;
    console.log('Starting at ' + (new Date()));
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
    tick = (function(_this) {
      return function() {
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
    })(this);
    return tick();
  };

  Engine.stop = function() {};

  Engine.startup = function() {};

  Engine.shutdown = function() {};

  Engine.update = function() {};

  Engine.draw = function() {
    var i, _i;
    Video.pixelBuf = Video.ctx.createImageData(Video.canvas.width, Video.canvas.height);
    for (i = _i = 0; _i < 10; i = ++_i) {
      Video.drawPixel(Math.rand(0, Video.canvas.width), Math.rand(0, Video.canvas.height), 255, 0, 0, 255);
    }
    return Video.updateCanvas();
  };

  return Engine;

})();

Vector3 = (function() {
  function Vector3(x, y, z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  return Vector3;

})();

Transform = (function() {
  function Transform() {}

  Transform.prototype.position = new Vector3(0, 0, 0);

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

Engine.run();
