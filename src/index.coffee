"use strict"

Error = require './Error'
BinboneEncoder = require './Encoder'
BinboneDecoder = require './Decoder'
QueueBuffer = require 'queue-buffer'

extend = (src, dest) ->
    for k, v of dest
        src[k] = v

class Block
    constructor: (arg, opts) ->
        @_data = new QueueBuffer arg, opts
        BinboneEncoder.call @, @_data
        BinboneDecoder.call @, @_data

    getData: ->
        @_data.toBuffer()

    inspect: ->
        @_data.inspect().replace '[QueueBuffer]', '[Binbone]'

extend Block::, BinboneEncoder::
extend Block::, BinboneDecoder::

module.exports = Block
module.exports.Encoder = BinboneEncoder
module.exports.Decoder = BinboneDecoder
module.exports.QueueBuffer = QueueBuffer
