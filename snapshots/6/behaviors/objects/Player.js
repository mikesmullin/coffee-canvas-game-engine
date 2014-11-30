// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['components/Behavior', 'components/Transform', 'components/SegmentCollider', 'scripts/CurrentPlayer', 'scripts/CurrentPlayerPlayer', 'scripts/AutoPilot'], function(Behavior, Transform, SegmentCollider, CurrentPlayer, CurrentPlayerPlayer, AutoPilot) {
    var Player;
    return Player = (function(_super) {
      __extends(Player, _super);

      function Player() {
        Player.__super__.constructor.apply(this, arguments);
        this.flashlightLit = true;
        this.transform = new Transform({
          object: this
        });
        this.collider = new SegmentCollider({
          object: this,
          is_trigger: true
        });
        this.BindScript(CurrentPlayer);
        this.BindScript(CurrentPlayerPlayer);
      }

      Player.prototype.ToggleFlashlight = function(force) {
        if ((force != null) && force === this.flashlightLit) {
          return;
        }
        if (this.flashlightLit = !this.flashlightLit) {
          return console.log('click.');
        } else {
          return console.log('click.');
        }
      };

      return Player;

    })(Behavior);
  });

}).call(this);
