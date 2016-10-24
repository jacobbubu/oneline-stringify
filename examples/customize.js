'use strict'

var {stringify, bgColorize, Render} = require('../lib/index')

var myRender = new Render()
myRender.STRING = function(paths, val) {
    var str = this.__proto__.STRING.call(this, paths, val)
    return bgColorize('red', str)
}

console.log(stringify(' RED ALERT! ', {render: myRender}))
