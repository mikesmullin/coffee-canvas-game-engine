// Generated by CoffeeScript 1.7.1
(function() {
  define(function() {
    var Input;
    return Input = (function() {
      function Input() {}

      Input.startup = function(cb) {
        var capturedMouseMove, focused, prefix, startX, startY, step;
        focused = false;
        step = 10;
        document.addEventListener('mousedown', (function(e) {
          focused = e.target === Video.canvas;
          if (!focused) {
            return;
          }
          return e.preventDefault();
        }), true);
        document.addEventListener('keydown', (function(e) {
          var _ref, _ref1, _ref2, _ref3;
          if (!focused) {
            return;
          }
          switch (e.keyCode) {
            case 87:
              if ((_ref = objects[whoami]) != null) {
                _ref.yT -= step;
              }
              break;
            case 65:
              if ((_ref1 = objects[whoami]) != null) {
                _ref1.xT -= step;
              }
              break;
            case 83:
              if ((_ref2 = objects[whoami]) != null) {
                _ref2.yT += step;
              }
              break;
            case 68:
              if ((_ref3 = objects[whoami]) != null) {
                _ref3.xT += step;
              }
          }
          return e.preventDefault();
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
            if ((_ref2 = objects[whoami]) != null) {
              _ref2.yT -= step;
            }
          } else {
            if ((_ref3 = objects[whoami]) != null) {
              _ref3.yT += step;
            }
          }
          return e.preventDefault();
        });
        prefix = Video.canvas.requestPointerLock ? '' : Video.canvas.mozRequestPointerLock ? 'moz' : 'webkit';
        Video.canvas.onclick = function() {
          return Video.canvas[(prefix ? prefix + 'R' : 'r') + 'equestPointerLock']();
        };
        capturedMouseMove = function(e) {
          var movX, movY, x, y, _ref, _ref1, _ref2, _ref3;
          movX = e[(prefix ? prefix + 'M' : 'm') + 'ovementX'];
          movY = e[(prefix ? prefix + 'M' : 'm') + 'ovementY'];
          x = e.clientX + movX;
          y = e.clientY + movY;
          if ((_ref = objects[whoami]) != null) {
            _ref.lastX || (_ref.lastX = x);
          }
          if ((_ref1 = objects[whoami]) != null) {
            _ref1.targetX = x;
          }
          if ((_ref2 = objects[whoami]) != null) {
            _ref2.lastY || (_ref2.lastY = y);
          }
          if ((_ref3 = objects[whoami]) != null) {
            _ref3.targetY = y;
          }
          return e.preventDefault();
        };
        document.addEventListener(prefix + 'pointerlockchange', (function() {
          if (document[(prefix ? prefix + 'P' : 'p') + 'ointerLockElement'] === Video.canvas) {
            console.log('The pointer lock status is now locked');
            return document.addEventListener('mousemove', capturedMouseMove, false);
          } else {
            console.log('The pointer lock status is now unlocked');
            return document.removeEventListener('mousemove', capturedMouseMove, false);
          }
        }), false);
        return cb();
      };

      return Input;

    })();
  });

}).call(this);
