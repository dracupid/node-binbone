"use strict"

{format} = require "util"

class DirkEncodeError extends Error
    constructor: ->
        @name = 'DirkEncodeError'
        @message = format.apply null, arguments
        Error.captureStackTrace @, arguments.callee

class DirkDecodeError extends Error
    constructor: ->
        @name = 'DirkDecodeError'
        @message = format.apply null, arguments
        Error.captureStackTrace @, arguments.callee

module.exports = {
    DirkEncodeError
    DirkDecodeError
}
