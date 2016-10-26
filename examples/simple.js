'use strict'

var {stringify} = require('../lib/index')

var printNumber = function (num) {
    console.log('Numbers:', num + ' => ' + stringify(1000))
}

var printDate = function (d) {
    console.log('Date:', d.toISOString() + ' => ' + stringify(d))
}

var printArray = function (arr, opts) {
    console.log('Array:', arr)
    console.log('      ', stringify(arr, opts))
}

var printObject = function (obj, opts) {
    console.log('Object:', obj)
    console.log('       ', stringify(obj, opts))
}

printNumber(1000)
printNumber(1.234)
console.log('String:', stringify('Hello, \t\r\n\b\f World!'))

printDate(new Date())
printDate(new Date('2015-10-01'))
printArray([1,'2',[3], 4, 5, 6], {maxitems: 4})

printObject({})
printObject({d: {}, c:{}, b:{}, a: {}}, {sort: true})
printObject({
    l1: {
        l1_1: [1,2,3],
        l1_2: {
            'l1-2-1': {},
        },
    },
    l2: {
        l2_1: 'l2_1',
        l2_2: '2002',
        l2_3: '2003',
        l2_4: '2004',
        l2_5: '2005',
    },
    l3: /.*/g
}, {maxitems: 4})
