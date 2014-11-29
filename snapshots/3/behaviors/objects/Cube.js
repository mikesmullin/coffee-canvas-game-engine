// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['../components/Behavior', '../components/Transform', '../components/MeshRenderer', '../lib/Vector3'], function(Behavior, Transform, MeshRenderer, Vector3) {
    var Cube;
    return Cube = (function(_super) {
      __extends(Cube, _super);

      function Cube() {
        Cube.__super__.constructor.apply(this, arguments);
        this.name = 'Cube';
        this.transform = new Transform({
          object: this
        });
        this.renderer = new MeshRenderer({
          object: this
        });
        this.renderer.materials = [
          {
            lineWidth: 2,
            strokeStyle: 'rgba(255, 0, 0, .8)',
            fillStyle: 'rgba(255, 0, 0, .5)'
          }
        ];
        this.renderer.arrayType = 'quads';
        this.renderer.vertices = [new Vector3(0, 0, 0), new Vector3(1, 0, 0), new Vector3(1, 1, 0), new Vector3(0, 1, 0)];
        this.transform.position = new Vector3(100, 100, 0);
        this.transform.localScale.Add(new Vector3(100, 100, 0));
      }

      Cube.prototype.Start = function(engine, cb) {
        engine.Log(this);
        return cb();
      };

      Cube.prototype.Update = function(engine) {
        var t;
        t = function(amplitude, period, x0, time) {
          return amplitude * Math.sin(time * 2 * Math.PI / period) + x0;
        };
        this.transform.position.x = t(4, 3, this.transform.position.x, engine.time);
        this.transform.position.y = t(2, 5, this.transform.position.y, engine.time);
        this.transform.localScale.x = t(2, 5, this.transform.localScale.x, engine.time);
        this.transform.localScale.y = t(2, 5, this.transform.localScale.y, engine.time);
        return this.transform.rotation.x = t(2, 3, 0, engine.time);
      };

      return Cube;

    })(Behavior);
  });

}).call(this);
