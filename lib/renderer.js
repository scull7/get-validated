
// `Renderer`
// ==========
// This is a simple error message template renderer.
// @param {string} name - parameter name
// @param {*} value - parameter value
// @param {string} template - the template string to render
function Renderer (name, value, template) {
  var message = template.replace(/:name/g, name);
  message     = message.replace(/:value/g, value + '');

  return message;
}
module.exports  = Renderer;