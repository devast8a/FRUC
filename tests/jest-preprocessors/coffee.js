// Generated by CoffeeScript 2.3.0
(function() {
  var coffee;

  coffee = require('coffeescript');

  exports.process = function(src, path) {
    if (coffee.helpers.isCoffee(path)) {
      return coffee.compile(src, {
        bare: true,
        inlineMap: true,
        filename: path
      });
    }
    return src;
  };

}).call(this);
