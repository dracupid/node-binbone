{DirkDecodeError} = require './Error'
util = require 'util'
BigInteger = require 'jsbn'
QueueBuffer = require 'queue-buffer'


class BinaryDecoder
    constructor: (inputBlock) ->
        @readFrom inputBlock

    readFrom: (inputBlock) ->
        if not (inputBlock instanceof QueueBuffer) and not (inputBlock instanceof QueueBuffer.__super__.constructor)
            throw new DirkEncodeError "input block should be a FlexBuffer or QueueBuffer."
        else
            @_input = inputBlock

    readByte: ->
        @_input.read 1

    skipByte: ->
        @_input.skip 1

    readBoolean: ->
        bool = @readByte()
        if bool is 1 then true else false

    skipBoolean: @::skipByte
    readBool: @::readBoolean
    skipBool: @::skipBoolean

    readUInt: ->
        oldOffset = @_input.offset
        b = @readByte()

        uint = b & 0x7F
        shift = 7

        while (b & 0x80) isnt 0
            try
                b = @readByte()
            catch e
                if b instanceof E.BinaryBlockDelayReadError
                    @_input.rewind @_input.offset - oldOffset
                throw e
            if uint instanceof BigInteger
                uint = uint.or((b & 0x7F) << shift)
            else
                uint |= (b & 0x7F) << shift
            shift += 7

        uint

    skipUInt: ->
        while (@readByte() & 0x80) isnt 0
            {}

    readLength: @::readUInt
    skipLength: @::skipUInt
    readSign: @::readUInt
    skipSign: @::skipUInt

    readInt: ->
        n = readUInt()
        (n >> 1) ^ -(n & 1)

    skipInt: @::skipUInt

    readLong: @::readInt
    skipLong: @::skipInt

    readFloat: ->
        bytes = @_input.read 4
        bytes.readFloatBE 0

    skipFloat: ->
        @_input.skip 4

    readDouble: ->
        bytes = @_input.read 8
        bytes.readDoubleBE 0

    skipDouble: ->
        @_input.skip 8

    readBytes: ->
        oldOffset = @_input.offset
        len = @readLength()
        if len and len > 0
            try
                bytes = @_input.read len
            catch e
                @_input.rewind @_input.offset - oldOffset
                throw e
        else
            new Buffer 0

    skipBytes: ->
        len = @readLength()
        @_input.skip len

    readString: ->
        bytes = @readBytes()

        if Buffer.isBuffer bytes
            bytes.toString()
        else
            String.fromCharCode(bytes)

    skipString: @::skipBytes

    readFixed: (len) ->
        if len > 0
            @_input.read len
        else
            new Buffer 0

    skipFixed: (len) ->
        @_input.skip len

    readArray: (type) ->
        self = @
        type = _.capitalize type.toLowerCase()
        if type is 'Uint' then type = 'UInt'

        fun = @["read#{type}"]
        if fun and not (type in ['From', 'Fixed'])
            oldOffset = @_input.offset
            res = []
            len = @readLength()
            try
                if len and len > 0
                    i = 0
                    while i < len
                        res.push fun.call self
                        i += 1
                res
            catch e
                @_input.rewind @_input.offset - oldOffset
                throw e
        else
            throw new DirkDecodeError "Unkonw type: #{type}"

    skipArray: (type) ->
        self = @
        type = _.capitalize type.toLowerCase()
        if type is 'Uint' then type = 'UInt'

        fun = @["skip#{type}"]
        if fun and not (type in ['From', 'Fixed'])
            len = @readLength()
            if len and len > 0
                i = 0
                while i < len
                    fun.call self
                    i += 1
        else
            throw new DirkDecodeError "Unkonw type: #{type}"

module.exports = BinaryDecoder
