Block = require '../src'
assert = require 'assert'
util = require 'util'

eq = assert.strictEqual
deq = assert.deepStrictEqual or assert.deepEqual
ts = assert.throws

describe "write byte", ->
    it "write default", ->
        B = new Block()
        B._data.fill 1
        l = B.writeByte()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write number", ->
        B = new Block()
        B.writeByte 120
        l = B.writeByte '1'
        eq l, 1
        eq B._data._buffer[0], 120
        eq B._data._buffer[1], 0x31

describe "write boolean", ->
    it "write default", ->
        B = new Block()
        B._data.fill 1
        l = B.writeBool()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write number", ->
        B = new Block()
        B.writeBool true
        l = B.writeBool '1'
        eq l, 1
        eq B._data._buffer[0], 1
        eq B._data._buffer[1], 1

describe "write Uint", ->
    it "write default", ->
        B = new Block()
        l = B.writeUInt()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write small uint", ->
        B = new Block()
        l = B.writeUInt 128
        eq l, 2
        deq B._data._buffer.slice(0, 2), new Buffer [0x80, 0x01]

        l = B.writeUInt 1234567
        eq l, 3
        deq B._data._buffer.slice(2, 5), new Buffer [0x87, 0xAD, 0x4B]
    it "write big uint", ->
        B = new Block()
        l = B.writeUInt "123456789012345"
        eq l, 5
        deq B._data._buffer.slice(0, 5), new Buffer [0xf9, 0xbe, 0xb7, 0xb0, 0x08]
    it "fix length - small", ->
        B = new Block()
        l = B.writeUInt 8, length: 4
        eq l, 4
        deq B._data._buffer.slice(0, 4), new Buffer [0, 0, 0, 8]
    it "fix length - big", ->
        B = new Block()
        l = B.writeUInt "123456789012345", length: 8
        eq l, 8
        deq B._data._buffer.slice(4, 8), new Buffer [0x86, 0x0d, 0xdf, 0x79]

describe "write Int", ->
    it "write default", ->
        B = new Block()
        l = B.writeInt()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write small int", ->
        B = new Block()
        l = B.writeInt 64
        eq l, 2
        deq B._data._buffer.slice(0, 2), new Buffer [0x80, 0x01]

        l = B.writeInt 1234567
        eq l, 4
        deq B._data._buffer.slice(2, 6), new Buffer [0x8e, 0xda, 0x96, 0x01]
    it "write big int", ->
        B = new Block()
        l = B.writeInt "123456789012345"
        eq l, 5
        deq B._data._buffer.slice(0, 5), new Buffer [0x8d, 0x82, 0x91, 0x9f, 0x0f]
    it "fix length - small", ->
        B = new Block()
        l = B.writeInt 8, length: 4
        eq l, 4
        deq B._data._buffer.slice(0, 4), new Buffer [0, 0, 0, 16]
    it "fix length - big", ->
        B = new Block()
        l = B.writeInt "123456789012345", length: 8
        eq l, 8
        deq B._data._buffer.slice(4, 8), new Buffer [0x0c, 0x1b, 0xbe, 0xf2]

describe "write float number", ->
    it "write float", ->
        B = new Block()
        l = B.writeFloat 123.123
        eq l, 4
        assert B._data.readFloatBE() - 123.123 < 0.0001

    it "write float", ->
        B = new Block()
        l = B.writeDouble 123.123
        eq l, 8
        assert B._data.readDoubleBE() - 123.123 < 0.0001

describe "write bytes", ->
    it "write default", ->
        B = new Block()
        B._data.fill 1
        l = B.writeBytes()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write array", ->
        B = new Block()
        l = B.writeBytes [1, 2, 3, 4]
        eq l, 5
        deq B._data.read(5), new Buffer [4, 1, 2, 3, 4]

    it "write buffer", ->
        B = new Block()
        l = B.writeBytes new Buffer [1, 2, 3, 4]
        eq l, 5
        deq B._data.read(5), new Buffer [4, 1, 2, 3, 4]

    describe "fixed length", ->
        it "throws length dismatch", ->
            B = new Block()
            ts -> l = B.writeBytes [1, 2, 3, 4], length: 7
        it "write bytes without length", ->
            B = new Block()
            l = B.writeBytes [1, 2, 3, 4], length: 4
            eq l, 4
            deq B._data.read(4), new Buffer [1, 2, 3, 4]

describe "write string", ->
    it "write default", ->
        B = new Block()
        B._data.fill 1
        l = B.writeString()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write ascii string", ->
        B = new Block()
        l = B.writeString "abcd"
        eq l, 5
        deq B._data.read(5), new Buffer [4, 97, 98, 99, 100]
    it "write utf-8 string", ->
        B = new Block()
        l = B.writeString "饼干雨水"
        eq l, 13
        B._data.read(1)
        deq B._data.read(12), new Buffer "饼干雨水"
    describe "fixed length", ->
        it "throws length dismatch", ->
            B = new Block()
            ts -> l = B.writeString "adff", length: 7
        it "write without length", ->
            B = new Block()
            l = B.writeString "adff", length: 4
            eq l, 4
            deq B._data.read(4).toString(), 'adff'

describe "write Map", ->
    it "key and value types are required", ->
        B = new Block()
        ts -> B.writeMap {}
        ts -> B.writeMap {}, keyType: 'string'
        ts -> B.writeMap {}, keyType: 'int'
    it "write default", ->
        B = new Block()
        l = B.writeMap null,
            keyType: 'string'
            valueType: 'uint'
        eq l, 1
        deq B._data.read(1), new Buffer [0]

    describe "use object", ->
        it "write plain object", ->
            B = new Block()
            map = a: 1, b: 2, c: 3

            l = B.writeMap map,
                keyType:
                    type: 'string'
                    length: 1
                valueType: 'uint'

            eq l, 7
            deq B._data.read(7), new Buffer [3, 97, 1, 98, 2, 99, 3]
        it "write object without function", ->
            B = new Block()
            map = a: 1, b: 2, c: 3, d: -> return

            l = B.writeMap map,
                keyType:
                    type: 'string'
                    length: 1
                valueType: 'uint'

            eq l, 7
            deq B._data.read(7), new Buffer [3, 97, 1, 98, 2, 99, 3]

        describe "Fixed length", ->
            it "throws length dismatch", ->
                B = new Block()
                map = a: 1, b: 2, c: 3
                ts ->
                    l = B.writeMap map,
                        length: 4
                        keyType: 'string'
                        valueType: 'uint'
            it "write map without length", ->
                B = new Block()
                map = a: 1, b: 2, c: 3
                l = B.writeMap map,
                    length: 3
                    keyType:
                        type: 'string'
                        length: 1
                    valueType: 'uint'

                eq l, 6
                deq B._data.read(6), new Buffer [97, 1, 98, 2, 99, 3]

    if typeof Map is 'function'
        describe "use ES6 Map", ->
            it "write plain map", ->
                B = new Block()
                map = new Map [['a', 1], ['b', 2], ['c', 3]]

                l = B.writeMap map,
                    keyType:
                        type: 'string'
                        length: 1
                    valueType: 'uint'

                eq l, 7
                deq B._data.read(7), new Buffer [3, 97, 1, 98, 2, 99, 3]
            it "write map without function", ->
                B = new Block()
                map = new Map [['a', 1], ['b', 2], ['c', 3], ['d', -> return]]
                l = B.writeMap map,
                    keyType:
                        type: 'string'
                        length: 1
                    valueType: 'uint'

                eq l, 7
                deq B._data.read(7), new Buffer [3, 97, 1, 98, 2, 99, 3]

            describe "Fixed length", ->
                it "throws length dismatch", ->
                    B = new Block()
                    map = new Map [['a', 1], ['b', 2], ['c', 3]]
                    ts ->
                        l = B.writeMap map,
                            length: 4
                            keyType: 'string'
                            valueType: 'uint'
                it "write map without length", ->
                    B = new Block()
                    map = new Map [['a', 1], ['b', 2], ['c', 3]]
                    l = B.writeMap map,
                        length: 3
                        keyType:
                            type: 'string'
                            length: 1
                        valueType: 'uint'

                    eq l, 6
                    deq B._data.read(6), new Buffer [97, 1, 98, 2, 99, 3]

describe "write array", ->
    it "write default", ->
        B = new Block()
        l = B.writeArray()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write typed array", ->
        B = new Block()
        l = B.writeArray [1, 2, 3, 5, 6], valueType: 'uint'
        eq l, 6
        deq B._data.read(6), new Buffer [5, 1, 2, 3, 5, 6]
    it "write non-typed array", ->
        B = new Block()
        l = B.writeArray [1, 2, 3]
        eq l, 7
        deq B._data.read(7), new Buffer [3, 4, 2, 4, 4, 4, 6]
    describe "fixed length", ->
        it "throws length dismatch", ->
            B = new Block()
            ts -> l = B.writeArray [1, 3, 4], length: 7
        it "write without length", ->
            B = new Block()
            l = B.writeArray [1, 2, 3, 4],
                length: 4
                valueType: 'uint'
            eq l, 4
            deq B._data.read(4), new Buffer [1, 2, 3, 4]

describe "write Object", ->
    it "write default", ->
        B = new Block()
        l = B.writeObject()
        eq l, 1
        eq B._data._buffer[0], 0
    it "write typed Object", ->
        B = new Block()
        l = B.writeObject {a: 1, b: 2, c: 3, d: -> return}, valueType: 'uint'
        eq l, 10
        deq B._data.read(10), new Buffer [3, 1, 97, 1, 1, 98, 2, 1, 99, 3]
    it "write non-typed Object", ->
        B = new Block()
        l = B.writeObject {a: 1, b: 2, c: 3, d: -> return}
        eq l, 13
        deq B._data.read(13), new Buffer [3, 1, 97, 4, 2, 1, 98, 4, 4, 1, 99, 4, 6]
    describe "fixed length", ->
        it "throws length dismatch", ->
            B = new Block()
            ts -> l = B.writeObject {a: 1, b: 2, c: 3}, length: 7
        it "write without length", ->
            B = new Block()
            l = B.writeObject {a: 1, b: 2, c: 3},
                length: 3
                valueType: 'uint'
            eq l, 9
            deq B._data.read(9), new Buffer [1, 97, 1, 1, 98, 2, 1, 99, 3]
