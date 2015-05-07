{DirkEncodeError} = require './Error'
util = require 'util'
QueueBuffer = require 'queue-buffer'
BigInteger = require 'jsbn'
MAX_JS_INT = Number.MAX_SAFE_INTEGER

{SIGN} = require './typeID'

cleanObj = (obj) ->
    res = {}
    for k, v of obj
        if v? and typeof v isnt 'function'
            res[k] = v
    res

isMap = (map) ->
    Object.prototype.toString.call(map) is '[object Map]'

getLen = (o, nonFun = false) ->
    if o.length? # Array, string
        o.lenth
    else if o.size? # Map
        o.size
    else
        if nonFun
            o = cleanObj o
        Object.keys(o).length

# return writed length
class BinaryEncoder
    ###*
     * constructor
     * @param  {Block} outputBlock An DirkBlock Object
    ###
    constructor: (outputBlock) ->
        @writeTo outputBlock
        @

    ###*
     * Reset data block
     * @param  {Block} outputBlock  see constructor
    ###
    writeTo: (outputBlock) ->
        if not (outputBlock instanceof QueueBuffer) and not (outputBlock instanceof QueueBuffer.__super__.constructor)
            throw new DirkEncodeError "output block should be a FlexBuffer or QueueBuffer."
        else
            @_output = outputBlock

    _funByType: (type) ->
        t = _.capitalize type.toLowerCase()
        t = 'UInt' if t is 'Uint'
        fun = @["write#{t}"]

        if not fun or t is 'To'
            throw new DirkEncodeError "Unkonw type [#{type}]"
        else
            fun

    _writeTypeFun: (type) ->
        self = @
        if typeof type is 'string'
            fun = _funByType type
            (value) ->
                fun.call self, value
        else if typeof type is 'object' and typeof type.type is 'string'
            fun = _funByType type.type
            (value) ->
                fun.call self, value, type
        else
            throw new DirkEncodeError "Unkonw type [#{type}]"

    _writeType: (type, value) ->
        @_writeTypeFun(type)(calue)

    _writeAuto: (data) ->
        len = 0
        if util.isBoolean v
            len += @writeSign SIGN.boolean
            len += @writeBoolean v
        else if util.isNumber v
            if Number.isInteger v
                len += @writeSign SIGN.int
                len += @writeInt v
            else
                len += @writeSign SIGN.double
                len += @writeDouble v
        else if util.isString v
            len += @writeSign SIGN.string
            len += @writeString v
        else if util.isArray v
            len += @writeSign SIGN.array
            len += @writeArray v
        else if util.isObject v
            len += @writeSign SIGN.object
            len += @writeObject v
        else
            len += @writeSign SIGN.string
            len += @writeString ''

        len

    _writeLength: (actual, expect, name) ->
        if expect?
            expect >>>= 0
            if actual isnt expect
                throw new DirkEncodeError "#{name} should be #{expect}, but get #{actual}"
            0
        else
            @writeLength actual

    ###*
     * Write a byte.
     * @param  {number=0} value     byte value
     * @return {number}             length to write (always 1)
    ###
    writeByte: (value = 0) ->
        @_output.write value
        1

    ###*
     * Write a boolean value.
     * @param  {boolean} value      boolean value
     * @return {number}             length to write (always 1)
     * @alias writeBool
    ###
    writeBoolean: (value) ->
        @writeByte if value then 1 else 0
        1

    writeBool: @::writeBoolean

    _writeUIntFixLength: (num, length) ->
        num = ~~num
        switch length >>> 0
            when 1
                @_output.writeUInt8 num
            when 2
                @_output.writeUInt16BE num
            when 4
                @_output.writeUInt32BE num
            when 8
                bytes = (new BigInteger num).toByteArray()
                len = bytes.length
                if len < 8
                    pad = new Array len - 8
                    bytes = pad.concat bytes
                else if len >= 8
                    bytes = bytes[len - 8...len]
                @_output.write new Buffer bytes
            else
                throw new DirkEncodeError "Unvalid integer length: #{length}."
        length

    ###*
     * Write an unsigned integer, using variable-length coding.
     * @param  {number=0 | string} num      integer, use string for any big integer
     * @param  {Object={}}         opts     options
     * @option {number}            length   byte length of integer (1, 2, 4, 8)
     * @return {number}                     length to write
     * @alias writeLength, writeSign
    ###
    writeUInt: (num = 0, opts = {}) ->
        length = opts.length
        if length?
            @_writeUIntFixLength num, length
        else
            len = 0
            if num > MAX_JS_INT
                num = new BigInteger num
                while num.and(~0x7F) isnt 0
                    len += @writeByte num.and(0x7F).or(0x80)
                    num = num.shiftRight 7
                @writeByte num
            else
                num = ~~num
                # Notice: num is 0
                while (num & ~0x7F) isnt 0
                    len += @writeByte (num & 0x7f) | 0x80
                    num >>>= 7
                @writeByte num
            len + 1

    writeLength: @::writeUInt
    writeSign: @::writeUInt

    ###*
     * Write an signed integer, using zig-zag variable-length coding.
     * @param  {Object={}}         opts     options
     * @option {number}            length   byte length of integer (1, 2, 4, 8)
     * @return {number}                     length to write
     * @alias writeLong
    ###
    writeInt: (num = 0, opts = {}) ->
        length = opts.length
        if length?
            num = ~~num
            switch length >>> 0
                when 1
                    num = (num << 1) ^ (num >> 7)
                when 2
                    num = (num << 1) ^ (num >> 15)
                when 4
                    num = (num << 1) ^ (num >> 31)
                when 8
                    num = (num << 1) ^ (num >> 63)
                else
                    throw new DirkEncodeError "Unvalid integer length: #{length}."
        else
            if num > MAX_JS_INT
                num = new BigInteger num
                byteLength = Math.ceil num.bitLength() / 8
                num = num.shiftLeft(1).xor(num.shiftRight(byteLength * 8 - 1))
            else
                num = ~~num
                num = (num << 1) ^ (num >> 63)

        @writeUInt num, opts

    writeLong: @::writeInt

    ###*
     * Write a float.
     * @param  {number=0} value     float point number
     * @return {number}             length to write (always 4)
    ###
    writeFloat: (value = 0) ->
        @_output.writeFloatBE value
        4

    ###*
     * Write a double.
     * @param  {number=0} value     float point number
     * @return {number}             length to write (always 8)
    ###
    writeDouble: (value = 0) ->
        @_output.writeDoubleBE value
        8

    ###*
     * Write bytes.
     * @param  {Array | Buffer} values      bytes
     * @param  {Object={}}      opts        options
     * @option {number}         length      number of bytes
     * @return {number}             length to write
    ###
    writeBytes: (values = [], opts = {}) ->
        if not Buffer.isBuffer(values) and not Array.isArray values
            throw new DirkEncodeError 'Bytes must be an array or a buffer.'

        length = opts.length
        byteLen = values.length
        len = 0

        len += @_writeLength byteLen, length, "Length of bytes"

        if byteLen
            len += @_output.write values
        len

    ###*
     * Write a string.
     * @param  {string}         str         string
     * @param  {Object={}}      opts        options
     * @option {number}         length      byte length of string
     * @return {number}                     length to write
    ###
    writeString: (str = '', opts = {}) ->
        str = str + ''
        length = opts.length
        strLen = Buffer.byteLength str
        len = 0

        len += @_writeLength strLen, length, "Byte length of string"

        if strLen is 0
            len += @_output.write str, 'utf8'
        len

    ###*
     * Write a map.
     * @param  {Object | Map = {}} map       key-value map
     * @param  {Object={}}    opts         options
     * @option {number}       length    size of map
     * @option {string|Object}       keyType      type of key[required]
     * @option {string|Object}       valueType    type of value[required]
     * @return {number}                           length to write
    ###
    writeMap: (map = {}, opts = {}) ->
        if typeof map isnt 'Object'
            throw new DirkEncodeError "Unvalid map type #{typeof map}."

        {keyType, valueType, length} = opts
        if not keyType
            throw new DirkEncodeError "Key type for map is missing."
        if not valueType
            throw new DirkEncodeError "Value type for map is missing."

        funKey = @_writeTypeFun keyType
        funValue = @_writeTypeFun valueType
        mapLen = getLen map, true
        len = 0

        len += @_writeLength mapLen, length, "Length of map"

        if mapLen
            if isMap map
                map.forEach (k, v) ->
                    len += funKey k
                    len += funValue v
            else
                for k, v of map
                    len += funKey k
                    len += funValue v
        len

    ###*
     * Write an array of data.
     * @param  {Array=[]} arr   Array
     * @param  {Object={}}      opts         options
     * @option {number}         length       length of array
     * @option {string|Object}  valueType    type of array item
     * @return {number}                      length to write
    ###
    writeArray: (arr = [], opts = {}) ->
        if not Array.isArray arr
            throw new DirkEncodeError "Wrong argument type, Array is required."

        {valueType, length} = opts
        arrLen = arr.length
        len = 0

        len += @_writeLength arrLen, length, "Array's length"

        if arrLen
            if not valueType
                for item in arr
                    len += @_writeAuto item
            else
                fun = @_writeTypeFun valueType
                for ite in arr
                    len += fun item
        len

    ###*
     * Write an object.
     * @param  {Object={}}      obj          object
     * @param  {Object={}}      opts         options
     * @option {number}         length       length of array
     * @option {string|Object}  valueType    type of object value
     * @return {number}                      length to write
    ###
    writeObject: (obj = {}, opts = {}) ->
        if typeof obj isnt 'object'
            throw new DirkEncodeError "Wrong argument type, Object is required."

        {valueType, length} = opts
        objLen = getLen obj, true
        len = 0

        len += @_writeLength objLen, length, "Object's size"

        if objLen
            if not valueType
                for k, v of obj
                    len += @writeString k
                    len += @_writeAuto v
            else
                fun = @_writeTypeFun valueType
                for k, v of obj
                    len += @writeString k
                    len += fun v

        len

module.exports = BinaryEncoder

