Error = require './Error'
DirkEncoder = require './Encoder'
DirkDecoder = require './Decoder'
QueueBuffer = require 'queue-buffer'

extend = (src, dest) ->
    for k, v of dest
        src[k] = v

class Block
    constructor: (arg, opts) ->
        @_data = new QueueBuffer arg, opts
        DirkEncoder.call @, @_data
        DirkDecoder.call @, @_data

extend Block::, DirkEncoder::
extend Block::, DirkDecoder::

module.exports = Block
module.exports.Encoder = DirkEncoder
module.exports.Decoder = DirkDecoder
module.exports.QueueBuffer = QueueBuffer
