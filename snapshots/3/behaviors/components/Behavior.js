// Generated by CoffeeScript 1.7.1
(function() {
  define(function() {
    var Behavior;
    return Behavior = (function() {
      function Behavior() {
        this.enabled = true;
        this.renderer = null;
        this.transform = null;
      }

      Behavior.prototype.start = function(cb) {
        return cb();
      };

      Behavior.prototype.update = function() {};

      Behavior.prototype.draw = function() {};

      return Behavior;

    })();
  });

}).call(this);
