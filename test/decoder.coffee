Block = require '../src'
assert = require 'assert'
util = require 'util'

eq = assert.strictEqual
deq = assert.deepStrictEqual or assert.deepEqual
ts = assert.throws

# read empty

describe "read byte", ->
    it "read a byte", ->
        B = new Block()
        B.writeByte 120
        eq B.readByte(), 120

    it "skip a byte", ->
        B = new Block()
        B.writeByte 120
        B.writeByte 12
        B.skipByte()
        eq B.readByte(), 12

describe "read boolean", ->
    it "read boolean", ->
        B = new Block()
        B._data.fill 1
        B.writeBool false
        eq B.readBool(), false

    it "skip boolean", ->
        B = new Block()
        B._data.fill 1
        B.writeBool true
        B.writeBool false
        B.skipBool()
        eq B.readBool(), false

describe "read UInt", ->
    it "read small UInt", ->
        B = new Block()
        B.writeUInt 12345
        eq B.readUInt(), 12345

    it "skip small uint", ->
        B = new Block()
        B.writeUInt 12345
        B.writeUInt 128
        B.skipUInt()
        eq B.readUInt(), 128

    it "read big uint", ->
        B = new Block()
        B.writeUInt "10123456789012345"
        eq B.readUInt(), "10123456789012345"

    it "skip big uint", ->
        B = new Block()
        B.writeUInt "123456723432423"
        B.writeUInt "123456723442345"
        B.skipUInt()
        eq B.readUInt(), "123456723442345"

    it "read fix length - small", ->
        B = new Block()
        B.writeUInt 8, length: 4
        eq B.readUInt(length: 4), 8

    it "skip fix length - small", ->
        B = new Block()
        B.writeUInt 8, length: 2
        B.writeUInt 16, length: 4
        B.skipUInt length: 2
        eq B.readUInt(length: 4), 16

    it "read fix length - big", ->
        B = new Block()
        B.writeUInt "123456789012345", length: 8
        eq B.readUInt(length: 8), "123456789012345"

    it "skip fix length - big", ->
        B = new Block()
        B.writeUInt "123456789012345", length: 8
        B.writeUInt "123456789012341", length: 8
        B.skipUInt(length: 8)
        eq B.readUInt(length: 8), "123456789012341"

describe "read Int", ->
    it "read small Int", ->
        B = new Block()
        B.writeInt 12345
        B.writeInt -12345
        eq B.readInt(), 12345
        eq B.readInt(), -12345

    it "skip small Int", ->
        B = new Block()
        B.writeInt 12345
        B.writeInt -128
        B.skipInt()
        eq B.readInt(), -128

    it "read big Int", ->
        B = new Block()
        B.writeInt "10123456789012345"
        eq B.readInt(), "10123456789012345"

    it "skip big Int", ->
        B = new Block()
        B.writeInt "123456723432423"
        B.writeInt "-123456723442345"
        B.skipInt()
        eq B.readInt(), "-123456723442345"

    it "read fix length - small", ->
        B = new Block()
        B.writeInt 8, length: 4
        eq B.readInt(length: 4), 8

    it "skip fix length - small", ->
        B = new Block()
        B.writeInt 8, length: 2
        B.writeInt 16, length: 4
        B.skipInt length: 2
        eq B.readInt(length: 4), 16

    it "read fix length - big", ->
        B = new Block()
        B.writeInt "123456789012345", length: 8
        eq B.readInt(length: 8), "123456789012345"

    it "skip fix length - big", ->
        B = new Block()
        B.writeInt "123456789012345", length: 8
        B.writeInt "123456789012341", length: 8
        B.skipInt(length: 8)
        eq B.readInt(length: 8), "123456789012341"

describe "read float number", ->
    it "read float", ->
        B = new Block()
        B.writeFloat 123.123
        assert B.readFloat() - 123.123 < 0.0001

    it "skip float", ->
        B = new Block()
        B.writeFloat -13.123
        B.writeFloat 123.123
        B.skipFloat()
        assert B.readFloat() - 123.123 < 0.0001

    it "read double", ->
        B = new Block()
        B.writeDouble 123.123
        assert B.readDouble() - 123.123 < 0.0001

    it "read double", ->
        B = new Block()
        B.writeDouble -123.123
        B.writeDouble 123.123
        B.skipDouble()
        assert B.readDouble() - 123.123 < 0.0001

describe "read bytes", ->
    it "read bytes", ->
        B = new Block()
        B.writeBytes [1..5]
        deq B.readBytes(), new Buffer [1..5]

    it "read with length", ->
        B = new Block()
        B.writeBytes [1..5], length: 5
        deq B.readBytes(length: 5), new Buffer [1..5]

    it "read too much", ->
        B = new Block()
        B.writeBytes [1..5], length: 5
        ts -> B.readBytes(length: 8)
        deq B.readBytes(length: 5), new Buffer [1..5]

    it "skip bytes", ->
        B = new Block()
        B.writeBytes [1..5]
        B.writeBytes [2..10]
        B.skipBytes()
        deq B.readBytes(), new Buffer [2..10]

    it "skip bytes with length", ->
        B = new Block()
        B.writeBytes [1..5], length: 5
        B.writeBytes [2..8]
        B.skipBytes length: 5
        deq B.readBytes(), new Buffer [2..8]

describe "read string", ->
    it "read string", ->
        B = new Block()
        B.writeString "你好"
        deq B.readString(), "你好"

    it "read with length", ->
        B = new Block()
        B.writeString "asdvs", length: 5
        deq B.readString(length: 5), "asdvs"

    it "read empty string", ->
        B = new Block()
        B.writeString ''
        eq B.readString(), ''


describe "read Map", ->
    useMap = do ->
        typeof Map is 'function'

    map = a: 1, b: 2, c: 3
    map2 = as: 12, bd: 22, ca: 13
    if useMap
        mapMap = new Map [['a', 1], ['b', 2], ['c', 3]]
        mapMap2 = new Map [['as', 12], ['bd', 22], ['ca', 13]]

    it "key and value types are required", ->
        B = new Block()
        ts -> B.readMap {}
        ts -> B.readMap {}, keyType: 'string'
        ts -> B.readMap {}, valueType: 'int'

    it "read object", ->
        B = new Block()
        opts =
            keyType:
                type: 'string'
            valueType: 'uint'
        B.writeMap map, opts
        if useMap
            deq B.readMap(opts), mapMap
        else
            deq B.readMap(opts), map

    it "read with length", ->
        B = new Block()
        opts =
            keyType:
                type: 'string'
                length: 1
            valueType: 'uint'
            length: 3

        B.writeMap map, opts
        if useMap
            deq B.readMap(opts), mapMap
        else
            deq B.readMap(opts), map

    it "read too much", ->
        B = new Block()
        opts =
            keyType:
                type: 'string'
                length: 1
            valueType: 'uint'
            length: 3

        B.writeMap map, opts
        opts.length = 4
        ts -> B.readMap(opts)
        opts.length = 3
        if useMap
            deq B.readMap(opts), mapMap
        else
            deq B.readMap(opts), map


    it "skip object", ->
        B = new Block()
        opts =
            keyType:
                type: 'string'
            valueType: 'uint'
        B.writeMap map, opts
        B.writeMap map2, opts
        B.skipMap opts
        if useMap
            deq B.readMap(opts), mapMap2
        else
            deq B.readMap(opts), map2

    it "skip with length", ->
        B = new Block()
        opts =
            keyType:
                type: 'string'
            valueType: 'uint'
            length: 3

        B.writeMap map, opts
        B.writeMap map2, opts
        B.skipMap opts
        if useMap
            deq B.readMap(opts), mapMap2
        else
            deq B.readMap(opts), map2

    it "read empty map", ->
        B = new Block()
        opts = {keyType: 'string', valueType: 'int'}
        B.writeMap {}, opts
        if useMap
            deq B.readMap(opts), new Map()
        else
            deq B.readMap(opts), {}

describe "read array", ->
    arr1 = [0...10]
    arr2 = [14...24]

    it "read array", ->
        arr = [1, 'sad', true, [1, 's', 1], a: 1]
        B = new Block()
        B.writeArray arr
        deq B.readArray(), arr

    it "read with length", ->
        B = new Block()
        B.writeArray arr1, length: 10
        deq B.readArray(length: 10), arr1

    it "read with type", ->
        B = new Block()
        B.writeArray arr1, valueType: 'uInt'
        deq B.readArray(valueType: 'uInt'), arr1

    it "read too much", ->
        B = new Block()
        B.writeArray arr1, length: 10
        ts -> B.readArray(length: 15)
        deq B.readArray(length: 10), arr1

    it "read empty array", ->
        B = new Block()
        B.writeArray []
        deq B.readArray(), []

    it "skip array", ->
        B = new Block()
        B.writeArray arr1
        B.writeArray arr2
        B.skipArray()
        deq B.readArray(), arr2

    it "skip with length", ->
        B = new Block()
        B.writeArray arr1, length: 10
        B.writeArray arr2
        B.skipArray(length: 10)
        deq B.readArray(), arr2

    it "skip with type", ->
        B = new Block()
        B.writeArray arr1, valueType: 'int'
        B.writeArray arr2
        B.skipArray(valueType: 'int')
        deq B.readArray(), arr2

describe "write Object", ->
    obj1 = a: 1, b: 2, c: 3
    obj2 = d: 4, e: 5, f: 6

    it "read object", ->
        obj = {a: 1, b: 'sa', c: true}
        B = new Block()
        B.writeObject obj
        deq B.readObject(), obj

    it "read with length", ->
        B = new Block()
        B.writeObject obj1, length: 3
        deq B.readObject(length: 3), obj1

    it "read with type", ->
        B = new Block()
        B.writeObject obj1, valueType: 'uInt'
        deq B.readObject(valueType: 'uInt'), obj1

    it "read too much", ->
        B = new Block()
        B.writeObject obj1, length: 3
        ts -> B.readObject(length: 5)
        deq B.readObject(length: 3), obj1

    it "read object", ->
        B = new Block()
        B.writeObject {}
        deq B.readObject(), {}

    it "skip Object", ->
        B = new Block()
        B.writeObject obj1
        B.writeObject obj2
        B.skipObject()
        deq B.readObject(), obj2

    it "skip with length", ->
        B = new Block()
        B.writeObject obj1, length: 3
        B.writeObject obj2
        B.skipObject(length: 3)
        deq B.readObject(), obj2

    it "skip with type", ->
        B = new Block()
        B.writeObject obj1, valueType: 'int'
        B.writeObject obj2
        B.skipObject(valueType: 'int')
        deq B.readObject(), obj2
