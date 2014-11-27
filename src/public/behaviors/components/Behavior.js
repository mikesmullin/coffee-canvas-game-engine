var behaviors;

behaviors = [];

define(function() {
  var Behavior;
  return Behavior = (function() {
    function Behavior(gameObject) {
      this.gameObject = gameObject;
      this.enabled = true;
      this.components = [];
      this.animation = null;
      this.audio = null;
      this.camera = null;
      this.collider2D = null;
      this.light = null;
      this.renderer = null;
      this.rigidbody2D = null;
      this.transform = null;
      this.id = behaviors.push(this);
    }

    Behavior.prototype.start = function() {};

    Behavior.prototype.update = function() {};

    Behavior.prototype.draw = function() {};

    return Behavior;

  })();
});
