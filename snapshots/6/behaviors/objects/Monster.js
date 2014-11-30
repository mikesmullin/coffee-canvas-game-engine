// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['components/Behavior', 'components/Transform', 'components/SegmentCollider', 'scripts/CurrentPlayer', 'scripts/CurrentMonsterPlayer', 'scripts/AutoPilot'], function(Behavior, Transform, SegmentCollider, CurrentPlayer, CurrentMonsterPlayer, AutoPilot) {
    var Monster;
    return Monster = (function(_super) {
      __extends(Monster, _super);

      function Monster() {
        Monster.__super__.constructor.apply(this, arguments);
        this.visible = true;
        this.transform = new Transform({
          object: this
        });
        this.collider = new SegmentCollider({
          object: this,
          is_trigger: true
        });
        this.BindScript(AutoPilot);
      }

      Monster.prototype.ToggleVisibility = function(force) {
        if ((force != null) && force === this.visible) {
          return;
        }
        if (this.visible = !this.visible) {
          this.renderer.materials[0].fillStyle = 'red';
          return console.log('begin scary monster music.');
        } else {
          this.renderer.materials[0].fillStyle = 'gray';
          return console.log('end scary monster music.');
        }
      };

      return Monster;

    })(Behavior);
  });

}).call(this);
