{ Render, DefaultColorMap, DefaultSymbols } = require './defaults'
ansiSlice = require 'ansi-slice'

stringify = (val, opts, paths=[]) ->
    render = opts.render
    return render.NULL(paths, val) unless val?

    type = Object::toString.call(val).charAt 8 # [object Function]
    return null if 'F' is type and !opts.showfunc

    # WARNING: output may not be jsonically parsable!
    if opts.custom
        if val.hasOwnProperty 'toString'
            return val.toString()
        else if val.hasOwnProperty 'inspect'
            return val.inspect()

    if 'N' is type
        if isNaN(val)
            render.NULL paths, val
        else
            render.NUMBER paths, val
    else if 'B' is type
        render.BOOL paths,val
    else if 'O' is type
        out = []
        if paths.length < opts.depth
            itemCount = 0
            keys = (k for k of val)
            keys = keys.sort() if opts.sort
            for key in keys
                if itemCount >= opts.maxitems
                    out.push render.REST_ITEMS paths, {
                        maxitems: opts.maxitems
                        length: keys.length
                        data: val
                    }
                    break
                pass = true
                for k in opts.exclude
                    pass = key.indexOf(k) < 0
                    break if !pass

                pass = pass and !opts.omitMap[key]
                if pass
                    itemCount++
                    valStr = stringify val[key], opts, [paths...,key]
                    if valStr?
                        out.push render.OBJECT_PROP(paths, { key, valStr })
        render.OBJECT paths, out
    else if 'A' is type
        out = []
        if paths.length <= opts.depth
            for i in [0...val.length]
                if i >= opts.maxitems
                    out.push render.REST_ITEMS paths, {
                        maxitems: opts.maxitems
                        length: val.length
                        data: val
                    }
                    break
                valStr = stringify val[i], opts, [paths..., i]
                out.push valStr if valStr?
            render.ARRAY paths, out
    else if val instanceof RegExp
        render.REG_EXP paths, val
    else if val instanceof Date
        render.DATE paths, val
    else
        render.STRING paths, val

module.exports =
    slice: (str, begin, end) -> ansiSlice str, begin, end
    stringify: (val, opts) ->
        opts ?= {}
        opts.showfunc ?= false
        opts.custom ?= false
        opts.depth ?= 6
        opts.sort ?= false
        opts.maxitems ?= 11
        opts.maxchars ?= 511
        opts.exclude ?= ['$']
        opts.noColor ?= false
        opts.colorMap ?= DefaultColorMap
        opts.symbols ?= DefaultSymbols
        opts.omit ?= []
        opts.omitMap = {}
        for f in opts.omit
            opts.omitMap[f] = true

        opts.render ?= new Render(opts) #DefaultRender

        stringify val, opts

    DefaultColorMap: DefaultColorMap
    DefaultSymbols: DefaultSymbols
    colorize: require('./colors').colorize
    bgColorize: require('./colors').bgColorize
    Render: Render
