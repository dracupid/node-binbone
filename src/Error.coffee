"use strict"

{format} = require "util"

class BinboneEncodeError extends Error
    constructor: ->
        @name = 'BinboneEncodeError'
        @message = format.apply null, arguments
        Error.captureStackTrace @, arguments.callee

class BinboneDecodeError extends Error
    constructor: ->
        @name = 'BinboneDecodeError'
        @message = format.apply null, arguments
        Error.captureStackTrace @, arguments.callee

module.exports = {
    BinboneEncodeError
    BinboneDecodeError
}
