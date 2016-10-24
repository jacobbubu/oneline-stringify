'use strict'

var moment = require('moment')
var {stringify, bgColors, Render} = require('../lib/index')
var { bgColorize } = bgColors

var myRender = new Render()
myRender.DATE = function(paths, val) {
    if (paths[0] === 'login') {
        if (paths[1] === 'latest') {
            return "'" + moment(val).fromNow() + "'"
        } else {
            return "'" + moment(val).format('YYYY-M-D') + "'"
        }
    } else {
        return this.__proto__.DATE.call(this, paths, val)
    }
}

var user = {
    login: {
        latest:  new Date(Date.now() - 3.2 * 60 * 1e3),
        first: new Date('2016-3-1 14:12:12')
    },
    createAt: new Date('2016-3-1 14:10:01')
}

console.log(stringify(user, {render: myRender}))
