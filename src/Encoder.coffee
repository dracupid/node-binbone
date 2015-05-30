"use strict"

{BinboneEncodeError} = require './Error'
util = require 'util'
QueueBuffer = require 'queue-buffer'
BigInteger = require 'jsbn'

{SIGN} = require './typeID'
$0x7F = new BigInteger 0x7F + ''
$A0x7F = new BigInteger ~0x7F + ''
$0x80 = new BigInteger 0x80 + ''
$0 = new BigInteger '0'

isMap = (map) ->
    Object.prototype.toString.call(map) is '[object Map]'

cleanObj = (obj) ->
    if isMap obj
        res = new Map()
        obj.forEach (v, k) ->
            if v? and typeof v isnt 'function'
                res.set(k, v)
    else
        res = {}
        for k, v of obj
            if v? and typeof v isnt 'function'
                res[k] = v
    res

getLen = (o, nonFun = false) ->
    if o.length? # Array, string
        o.lenth
    else if o.size? # Map
        o.size
    else
        Object.keys(o).length

Number.isInteger = Number.isInteger or (value) ->
    typeof value is "number" and
        isFinite(value) and
        Math.floor(value) is value

class BinaryEncoder
    ###*
     * constructor
     * @param  {FlexBuffer} outputBlock     An BinboneBlock Object
    ###
    constructor: (outputBlock) ->
        unless outputBlock
            outputBlock = new QueueBuffer()
        @writeTo outputBlock
        @

    ###*
     * Reset data block
     * @param  {FlexBuffer} outputBlock     An BinboneBlock Object
    ###
    writeTo: (outputBlock) ->
        if not (outputBlock instanceof QueueBuffer) and not (outputBlock instanceof QueueBuffer.__super__.constructor)
            throw new BinboneEncodeError "output block should be a FlexBuffer or QueueBuffer."
        else
            @_output = outputBlock

    _writeTypeFun: (type) ->
        self = @

        _funByType = (type) ->
            t = type.toLowerCase()
            t = t.charAt(0).toUpperCase() + t.slice(1)

            t = 'UInt' if t is 'Uint'
            fun = self["write#{t}"]

            if not fun or t is 'To'
                throw new BinboneEncodeError "Unknown type [#{type}]"
            else
                fun

        if typeof type is 'string'
            fun = _funByType type
            (value) ->
                fun.call self, value
        else if typeof type is 'object' and typeof type.type is 'string'
            fun = _funByType type.type
            (value) ->
                fun.call self, value, type
        else
            throw new BinboneEncodeError "Unkonw type [#{type}]"

    _writeType: (type, value) ->
        @_writeTypeFun(type)(value)

    _writeAuto: (v) ->
        len = 0
        if typeof v is 'boolean'
            len += @writeSign SIGN.boolean
            len += @writeBoolean v
        else if typeof v is 'number'
            if Number.isInteger v
                len += @writeSign SIGN.int
                len += @writeInt v
            else
                len += @writeSign SIGN.double
                len += @writeDouble v
        else if typeof v is 'string'
            len += @writeSign SIGN.string
            len += @writeString v
        else if util.isArray v
            len += @writeSign SIGN.array
            len += @writeArray v
        else if typeof v is 'object'
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
                throw new BinboneEncodeError "#{name} should be #{expect}, but get #{actual}"
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
        switch length >>> 0
            when 1
                @_output.writeUInt8 ~~num
            when 2
                @_output.writeUInt16BE ~~num
            when 4
                @_output.writeUInt32BE ~~num
            when 8
                if num instanceof BigInteger
                    bytes = num
                else
                    bytes = new BigInteger num
                bytes = bytes.toByteArray()
                len = bytes.length
                if len < 8
                    pad = new Array 8 - len
                    bytes = pad.concat bytes
                else if len >= 8
                    bytes = bytes[len - 8...len]
                @_output.write new Buffer bytes
            else
                throw new BinboneEncodeError "Unvalid integer length: #{length}."
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
            if not (num instanceof BigInteger) and num > Math.pow(2, 31)
                num = new BigInteger num + ''

            if num instanceof BigInteger
                while not num.and($A0x7F).equals($0)
                    len += @writeByte parseInt num.and($0x7F).or($0x80).toRadix 10
                    num = num.shiftRight 7
                @writeByte parseInt num.toRadix 10
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
            switch length >>> 0
                when 1
                    num = ~~num
                    num = (num << 1) ^ (num >> 7)
                when 2
                    num = ~~num
                    num = (num << 1) ^ (num >> 15)
                when 4
                    num = ~~num
                    num = (num << 1) ^ (num >> 31)
                when 8
                    num = new BigInteger num
                    num = num.shiftLeft(1).xor(num.shiftRight(63))
                else
                    throw new BinboneEncodeError "Unvalid integer length: #{length}."
        else
            if num > Math.pow(2, 31) or num < -Math.pow(2, 31)
                num = new BigInteger num + ''
                byteLength = Math.ceil num.bitLength() / 8
                num = num.shiftLeft(1).xor(num.shiftRight(8 * byteLength - 1))
            else
                num = ~~num
                num = (num << 1) ^ (num >> 31)
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
            throw new BinboneEncodeError 'Bytes must be an array or a buffer.'

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

        if strLen isnt 0
            len += @_output.write str, 'utf8'
        len

    ###*
     * Write a map.
     * @param  {Object | Map = {}} map       key-value map
     * @param  {Object={}}    opts         options
     * @option {number}       length    size of map
     * @option {string|Object}       keyType      type of key [required]
     * @option {string|Object}       valueType    type of value [required]
     * @return {number}                           length to write
    ###
    writeMap: (map = {}, opts = {}) ->
        if typeof map isnt 'object'
            throw new BinboneEncodeError "Unvalid map type [#{typeof map}]."

        {keyType, valueType, length} = opts
        if not keyType
            throw new BinboneEncodeError "Key type for map is missing."
        if not valueType
            throw new BinboneEncodeError "Value type for map is missing."

        funKey = @_writeTypeFun keyType
        funValue = @_writeTypeFun valueType
        map = cleanObj map
        mapLen = getLen map, true
        len = 0

        len += @_writeLength mapLen, length, "Length of map"

        if mapLen
            if isMap map
                map.forEach (v, k) ->
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
            throw new BinboneEncodeError "Wrong argument type, Array is required."

        {valueType, length} = opts
        arrLen = arr.length
        len = 0

        len += @_writeLength arrLen, length, "Length of array"

        if arrLen
            if not valueType
                for item in arr
                    len += @_writeAuto item
            else
                fun = @_writeTypeFun valueType
                for item in arr
                    len += fun item
        len

    ###*
     * Write an object.
     * @param  {Object={}}      obj          object
     * @param  {Object={}}      opts         options
     * @option {number}         length       size of object
     * @option {string|Object}  valueType    type of object value
     * @return {number}                      length to write
    ###
    writeObject: (obj = {}, opts = {}) ->
        if typeof obj isnt 'object'
            throw new BinboneEncodeError "Wrong argument type, Object is required."

        {valueType, length} = opts
        obj = cleanObj obj
        objLen = getLen obj, true
        len = 0

        len += @_writeLength objLen, length, "Size of object"

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

