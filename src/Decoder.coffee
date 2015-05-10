"use strict"

{BinboneDecodeError} = require './Error'
util = require 'util'
BigInteger = require 'jsbn'
QueueBuffer = require 'queue-buffer'
MAX_JS_INT = Number.MAX_SAFE_INTEGER or Math.pow(2, 53) - 1
$1 = new BigInteger '1'

{RSIGN} = require './typeID'

isDelayError = (e) ->
    e.name = 'QueueDelayError'

class BinaryDecoder
    ###*
     * constructor
     * @param  {QueueBuffer} inputBlock      An QueueBuffer Object
    ###
    constructor: (inputBlock) ->
        unless inputBlock
            inputBlock = new QueueBuffer()
        @readFrom inputBlock
        @

    ###*
     * Reset data block
     * @param  {QueueBuffer} inputBlock      An QueueBuffer Object
    ###
    readFrom: (inputBlock) ->
        if not inputBlock instanceof QueueBuffer
            throw new BinboneDecodeError "input block should be a QueueBuffer."
        else
            @_input = inputBlock

    _buildTypeFun: (name, type) ->
        self = @

        _funByType = (type) ->
            t = type.toLowerCase()
            t = t.charAt(0).toUpperCase() + t.slice(1)

            t = 'UInt' if t is 'Uint'
            fun = self["#{name}#{t}"]

            if not fun or t is 'From'
                throw new BinboneDecodeError "Unknown type [#{type}]"
            else
                fun

        if typeof type is 'string'
            fun = _funByType type
            (value) ->
                fun.call self
        else if typeof type is 'object' and typeof type.type is 'string'
            fun = _funByType type.type
            (value) ->
                fun.call self, type
        else
            throw new BinboneDecodeError "Unkonw type [#{type}]"

    _readTypeFun: (type) ->
        @_buildTypeFun 'read', type

    _skipTypeFun: (type) ->
        @_buildTypeFun 'skip', type

    _readType: (type, value) ->
        @_readTypeFun(type)(value)

    _skipType: (type, value) ->
        @_skipTypeFun(type)(value)

    _typeBySign: (sign) ->
        typeSign = sign & 0x0F
        optSign = sign & 0xF0 >>> 4
        typeStr = RSIGN[typeSign]
        opt = {}

        if (typeSign is 0x03) and optSign
            type: typeStr
            length: optSign
        else if (typeSign is 0x0B) and (optSign is 0x01)
            type: typeStr
            valueType: @_typeBySign optSign
        else
            typeStr

    _readAuto: ->
        type = @_typeBySign @readSign()
        @_readType type

    _skipAuto: ->
        type = @_typeBySign @readSign()
        @_skipType type

    _readLength: (expect) ->
        if expect?
            expect >>>= 0
        else
            @readLength()
    ###*
     * Read a single byte.
     * @return {number} byte
    ###
    readByte: ->
        @_input.read(1)[0]

    ###*
     * Skip a single byte.
     * @param
    ###
    skipByte: ->
        @_input.skip 1

    ###*
     * Read boolean value.
     * @return {Boolean} boolean value
     * @alias readBool
    ###
    readBoolean: ->
        bool = @readByte()
        if bool is 1 then true else false

    ###*
     * skip a boolean value.
     * @alias skipBool
     * @param
    ###
    skipBoolean: @::skipByte
    readBool: @::readBoolean
    skipBool: @::skipBoolean

    _readUIntFixLength: (length) ->
        switch length >>> 0
            when 1
                uint = @_input.readUInt8()
            when 2
                @_input.readUInt16BE()
            when 4
                @_input.readUInt32BE()
            when 8
                bytes = @_input.read 8
                '' + new BigInteger bytes
            else
                throw new BinboneDecodeError "Unvalid integer length: #{length}."

    ###*
     * Read an unsigned integer.
     * @param  {Object={}}    opts     options
     * @option {number}    length   byte length of integer (1, 2, 4, 8)
     * @return {number|string}      integer, string for big integer
     * @alias readLength, readSign
    ###
    readUInt: (opts = {}) ->
        length = opts.length
        if length?
            @_readUIntFixLength length
        else
            oldOffset = @_input.offset
            b = @readByte()

            uint = b & 0x7F
            shift = 7

            while (b & 0x80) isnt 0
                try
                    b = @readByte()
                catch e
                    if isDelayError e
                        @_input.rewind @_input.offset - oldOffset
                    throw e

                if shift >= 28
                    unless uint instanceof BigInteger
                        uint = new BigInteger uint + ''
                    uint = uint.or (new BigInteger((b & 0x7F) + '')).shiftLeft shift
                else
                    uint |= (b & 0x7F) << shift

                shift += 7

            if uint instanceof BigInteger
                (new BigInteger [0].concat uint.toByteArray()).toString()
            else
                uint >>> 0

    ###*
     * Skip an unsigned integer.
     * @param  {Object={}}    opts     options (see readUint)
     * @alias skipLength, skipSign
    ###
    skipUInt: (opts = {}) ->
        if opts.length
            length = opts.length >>> 0
            if length in [1, 2, 4, 8]
                @_input.skip length
            else
                throw new BinboneDecodeError "Unvalid integer length: #{length}."
        else
            while (@readByte() & 0x80) isnt 0
                {}

    readLength: @::readUInt
    skipLength: @::skipUInt
    readSign: @::readUInt
    skipSign: @::skipUInt

    ###*
     * Read an signed integer.
     * @param  {Object={}}    opts     options
     * @option {number}    length   byte length of integer (1, 2, 4, 8)
     * @return {number|string}      integer, string for big integer
     * @alias  readLong
    ###
    readInt: (opts = {}) ->
        n = @readUInt opts
        if typeof n is 'string'
            n = new BigInteger n
            n.shiftRight(1).xor(n.and($1).negate()).toString()
        else
            (n >> 1) ^ -(n & 1)

    ###*
     * Skip a signed integer.
     * @param  {Object={}}    opts     options(see readInt)
     * @alias skipLong
    ###
    skipInt: @::skipUInt

    readLong: @::readInt
    skipLong: @::skipInt

    ###*
     * Read a float.
     * @return {Number} float number
    ###
    readFloat: ->
        @_input.readFloatBE()

    ###*
     * Skip a float.
     * @param
    ###
    skipFloat: ->
        @_input.skip 4

    ###*
     * Read a double.
     * @return {number} double number
    ###
    readDouble: ->
        @_input.readDoubleBE()

    ###*
     * Skip a double.
     * @param
    ###
    skipDouble: ->
        @_input.skip 8

    ###*
     * Read bytes.
     * @param  {Object={}}      opts        options
     * @option {number}         length      number of bytes
     * @return {Buffer}         bytes
    ###
    readBytes: (opts = {}) ->
        len = @_readLength opts.length
        oldOffset = @_input._readOffset
        try
            @_input.read len
        catch e
            @_input.rewind @_input._readOffset - oldOffset
            throw e

    ###*
     * Skip bytes
     * @param  {Object={}}      opts        options(see readBytes)
    ###
    skipBytes: (opts = {}) ->
        len = @_readLength opts.length
        @_input.skip len

    ###*
     * Read a string.
     * @param  {Object={}}      opts        options
     * @option {number}         length      byte length of string
     * @return {string}                     string
    ###
    readString: (opts = {}) ->
        bytes = @readBytes opts
        bytes.toString()

    ###*
     * Skip a string.
     * @param  {Object={}}      opts        options(see readString)
    ###
    skipString: @::skipBytes

    ###*
     * Read a map.
     * @param  {Object={}}          opts         options
     * @option {number}             length    size of map
     * @option {string|Object}       keyType      type of key[required]
     * @option {string|Object}       valueType    type of value[required]
     * @return {Map(es6)|Object(else)}  map
    ###
    readMap: (opts = {}) ->
        {keyType, valueType, length} = opts
        if not keyType
            throw new BinboneDecodeError "Key type for map is missing."
        if not valueType
            throw new BinboneDecodeError "Value type for map is missing."

        funKey = @_readTypeFun keyType
        funValue = @_readTypeFun valueType

        len = @_readLength length
        oldOffset = @_input._readOffset

        try
            if typeof Map is 'function'
                map = new Map()
                for item in [0...len]
                    map.set funKey(), funValue()
            else
                map = {}
                for item in [0...len]
                    map[funKey()] = funValue()
            map
        catch e
            @_input.rewind @_input._readOffset - oldOffset
            throw e

    ###*
     * Skip a map.
     * @param  {Object={}}          opts         options(see readMap)
    ###
    skipMap: (opts = {}) ->
        {keyType, valueType, length} = opts
        if not keyType
            throw new BinboneDecodeError "Key type for map is missing."
        if not valueType
            throw new BinboneDecodeError "Value type for map is missing."

        len = @_readLength length
        funKey = @_skipTypeFun keyType
        funValue = @_skipTypeFun valueType
        for item in [0...len]
            funKey()
            funValue()

    ###*
     * Read an array.
     * @param  {Object={}}      opts         options
     * @option {number}         length       length of array
     * @option {string|Object}  valueType    type of array item
     * @return {Array}                       array
    ###
    readArray: (opts = {}) ->
        {valueType, length} = opts
        len = @_readLength length
        oldOffset = @_input._readOffset
        arr = new Array len

        try
            if not valueType
                for i in [0...len]
                    arr[i] = @_readAuto()
            else
                funValue = @_readTypeFun valueType
                for i in [0...len]
                    arr[i] = funValue()
            arr
        catch e
            @_input.rewind @_input._readOffset - oldOffset
            throw e

    ###*
     * Skip an array.
     * @param  {Object={}}      opts         options(see readArray)
    ###
    skipArray: (opts = {}) ->
        {valueType, length} = opts
        len = @_readLength length

        if not valueType
            for i in [0...len]
                @_skipAuto()
        else
            funValue = @_skipTypeFun valueType
            for i in [0...len]
                funValue()

    ###*
     * Read an object.
     * @param  {Object={}}      opts         options
     * @option {number}         length       size of object
     * @option {string|Object}  valueType    type of object value
     * @return {Object}                      object
    ###
    readObject: (opts = {}) ->
        {valueType, length} = opts
        len = @_readLength length
        oldOffset = @_input._readOffset
        obj = {}

        try
            if not valueType
                for i in [0...len]
                    obj[@readString()] = @_readAuto()
            else
                funValue = @_readTypeFun valueType
                for i in [0...len]
                    obj[@readString()] = funValue()
            obj
        catch e
            @_input.rewind @_input._readOffset - oldOffset
            throw e

    ###*
     * Skip an array.
     * @param  {Object={}}      opts         options(see readObject)
    ###
    skipObject: (opts = {}) ->
        {valueType, length} = opts
        len = @_readLength length

        if not valueType
            for i in [0...len]
                @readString()
                @_readAuto()
        else
            funValue = @_readTypeFun valueType
            for i in [0...len]
                @readString()
                funValue()

module.exports = BinaryDecoder
