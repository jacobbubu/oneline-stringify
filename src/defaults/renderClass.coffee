{ colorize } = require '../colors'
DefaultColorMap = require './colorMap'
DefaultSymbols = require './symbols'

REG_EXP_PATTERN = /^(\/)(.*)((?:\/)(?:[a-z]*)$)/

shortenNumber = (num) ->
    str = '' + num
    exp = ('' + num.toExponential()).replace '+', ''
    if exp.length < str.length then exp else str

objectWraper = (symbols, paths, colors) ->
    colorName = colors.ColorsByDepth[(paths.length) % colors.ColorsByDepth.length]
    [
        colorize(colorName, symbols.OBJECT_WRAPPER_CHAR[0])
        colorize(colorName, symbols.OBJECT_WRAPPER_CHAR[1])
    ]

arrayWraper = (symbols, paths, colors) ->
    colorName = colors.ColorsByDepth[(paths.length) % colors.ColorsByDepth.length]
    [
        colorize(colorName, symbols.ARRAY_WRAPPER_CHAR[0])
        colorize(colorName, symbols.ARRAY_WRAPPER_CHAR[1])
    ]

lower = (str) ->
    str = '' + str
    cgj = '\u034f'
    (c + cgj for c in str).join ''

Render = (opts) ->
    @opts = {}
    @opts.noColor = opts?.noColor ? false
    @opts.colorMap = opts?.colorMap ? DefaultColorMap
    @opts.symbols = opts?.symbols ? DefaultSymbols
    @

Render.prototype =
    NULL: (paths, val) ->
        if @opts.noColor then 'null' else colorize(@opts.colorMap.NULL, 'null')

    NUMBER: (paths, val) ->
        str = shortenNumber val
        if @opts.noColor then str else colorize(@opts.colorMap.NUMBER, str)

    OBJECT_PROP: (paths, val) ->
        key = if val.key.match(/^[a-zA-Z0-9_$]+$/) then val.key else "'#{val.key}'"
        key = colorize(@opts.colorMap.OBJECT_KEY, key) unless @opts.noColor
        result = key

        if val.key isnt val.valStr
            if @opts.noColor
                result += ':' + val.valStr
            else
                result += colorize(@opts.colorMap.KEY_NAME_DIVIDER, ':') + val.valStr
        result

    OBJECT: (paths, val) ->
        opts = @opts
        emptyObject = () ->
            str = opts.symbols.EMPTY_OBJECT_CHAR
            str = colorize(opts.colorMap.EMPTY_OBJECT, str) unless opts.noColor

        comma = if opts.noColor then ',' else colorize(opts.colorMap.OBJECT_COMMA, ',')
        if paths.length is 0
            # no curry brackets for root level object
            if val.length
                result = val.join comma
            else
                result = emptyObject()
        else if val.length
            if opts.noColor
                result =  OBJECT_WRAPPER_CHAR[0] + val.join(comma) + OBJECT_WRAPPER_CHAR[1]
            else
                coloredWrappers = objectWraper(opts.symbols, paths, opts.colorMap)
                result =  coloredWrappers[0] + val.join(comma) + coloredWrappers[1]
        else
            result = emptyObject()
        result

    ARRAY: (paths, val) ->
        comma = if @opts.noColor then ',' else colorize(@opts.colorMap.ARRAY_COMMA, ',')

        if val.length
            coloredWrappers = arrayWraper(@opts.symbols, paths, @opts.colorMap)
            result = coloredWrappers[0] + val.join(comma) + coloredWrappers[1]
        else
            result = colorize @opts.colorMap.EMPTY_ARRAY, @opts.symbols.EMPTY_ARRAY_CHAR
        result

    BOOL: (paths, val) ->
        result = if !!val then @opts.symbols.TRUE_SYMBOL else @opts.symbols.FALSE_SYMBOL
        result = colorize(@opts.colorMap.BOOL, result) unless @opts.noColor
        result

    REG_EXP: (paths, val) ->
        result = val.toString()
        m = result.match REG_EXP_PATTERN
        if m and !@opts.noColor
            result = colorize(@opts.colorMap.REG_EXP_WRAPPER, m[1]) +
                colorize(@opts.colorMap.REG_EXP, m[2]) +
                colorize(@opts.colorMap.REG_EXP_WRAPPER, m[3])
        result

    DATE: (paths, val) ->
        # remove year part if it equals to current year
        str = val.toISOString() # 2016-10-23T02:39:30.602Z

        [year, month, date] = [val.getFullYear(), val.getMonth() + 1, val.getDate()]
        [hours, minutes, seconds] = [val.getHours(), val.getMinutes(), val.getSeconds()]
        msecs = val.getMilliseconds()

        currYear = new Date().getFullYear()
        result = if year is currYear then '' else '' + year + '-'
        result += "#{month}-#{date}"
        result += " #{hours}:#{minutes}:#{seconds}.#{msecs}"

        # result = if str[0..4] is currYear then str[5..] else str
        # result = result.replace(/0([0-9][:-T.])/g, '$1')

    STRING: (paths, val) ->
        result = val.toString().replace(/[\r]/g, '\u240d') # LF
            .replace(/[\n]/g, '\u240a')                    # CR
            .replace(/[\t]/g, '\u2409')                    # TAB
            .replace(/[\v]/g, '\u240b')                    # vertical TAB
            .replace(/[\b]/g, '\u2408')                    # backspace
            .replace(/[\f]/g, '\u240c')                    # form

    REST_ITEMS: (paths, val) ->
        left = val.length - val.maxitems
        result = "…#{lower(left)}"
        unless @opts.noColor
            result = colorize @opts.colorMap.REST_ITEMS, result
        result

    ELSE: (paths, val) ->
        result = val.toString()

module.exports = Render