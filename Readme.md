node-binbone
=================
Node.js(io.js) implemention of [binbone](doc/spec.md), A binary encode specification aimed at achieving optimal space utilization.

[![NPM version](https://badge.fury.io/js/binbone.svg)](https://www.npmjs.com/package/node-binbone)
[![Build Status](https://travis-ci.org/dracupid/node-binbone.svg)](https://travis-ci.org/dracupid/node-binbone)
[![Build status](https://ci.appveyor.com/api/projects/status/github/dracupid/node-binbone?svg=true)](https://ci.appveyor.com/project/dracupid/node-binbone)

## Installation
```bash
npm i binbone -S
```

## Usage
- Use Block. Block can be use as both an encoder and a decoder.

```javascript
Block = require("binbone");
block = new Block(1024); // args are the same as a QueueBuffer

block.writeArray([1, 2, 3]);
block.writeUInt("123456789012345"); // Big integer(use [jsbn](https://github.com/andyperlitch/jsbn))
block.readArray();
block.readUInt();
```

- Use encoder/decoder.

Directly:

```javascript
Encoder = require("binbone").Encoder;
encodeBlock = new Encoder();

encodeBlock.writeInt(123);
```

Specify a Buffer for data:

```javascript
binbone = require('binbone');
buf = new binbone.QueueBuffer();
buf.writeUInt16BE(12);
decoder = new binbone.Decoder(buf);
decoder.readUInt({length: 2});
```

## API


### Encoder

- #### <a href="./src/Encoder.coffee?source#L48" target="_blank"><b>constructor (outputBlock)</b></a>
    constructor

  - **param**: `outputBlock` { _FlexBuffer_ }

    An BinboneBlock Object

- #### <a href="./src/Encoder.coffee?source#L58" target="_blank"><b>writeTo (outputBlock)</b></a>
    Reset data block

  - **param**: `outputBlock` { _FlexBuffer_ }

    An BinboneBlock Object

- #### <a href="./src/Encoder.coffee?source#L134" target="_blank"><b>writeByte (value = 0)</b></a>
    Write a byte.

  - **param**: `value` { _number=0_ }

    byte value

  - **return**:  { _number_ }

    length to write (always 1)

- #### <a href="./src/Encoder.coffee?source#L144" target="_blank"><b>writeBoolean (value)  <small>(alias: writeBool)</small> </b></a>
    Write a boolean value.

  - **param**: `value` { _boolean_ }

    boolean value

  - **return**:  { _number_ }

    length to write (always 1)

- #### <a href="./src/Encoder.coffee?source#L183" target="_blank"><b>writeUInt (num = 0 | string, opts = {})  <small>(alias: writeLength, writeSign)</small> </b></a>
    Write an unsigned integer, using variable-length coding.

  - **param**: `num` { _number=0 | string_ }

    integer, use string for any big integer

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **return**:  { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L216" target="_blank"><b>writeInt (opts = {})  <small>(alias: writeLong)</small> </b></a>
    Write an signed integer, using zig-zag variable-length coding.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **return**:  { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L251" target="_blank"><b>writeFloat (value = 0)</b></a>
    Write a float.

  - **param**: `value` { _number=0_ }

    float point number

  - **return**:  { _number_ }

    length to write (always 4)

- #### <a href="./src/Encoder.coffee?source#L260" target="_blank"><b>writeDouble (value = 0)</b></a>
    Write a double.

  - **param**: `value` { _number=0_ }

    float point number

  - **return**:  { _number_ }

    length to write (always 8)

- #### <a href="./src/Encoder.coffee?source#L271" target="_blank"><b>writeBytes (values, opts = {})</b></a>
    Write bytes.

  - **param**: `values` { _Array | Buffer_ }

    bytes

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    number of bytes

  - **return**:  { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L292" target="_blank"><b>writeString (str, opts = {})</b></a>
    Write a string.

  - **param**: `str` { _string_ }

    string

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    byte length of string

  - **return**:  { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L313" target="_blank"><b>writeMap (map =  {}, opts = {})</b></a>
    Write a map.

  - **param**: `map` { _Object | Map = {}_ }

    key-value map

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    size of map

  - **option**: `keyType` { _string|Object_ }

    type of key [required]

  - **option**: `valueType` { _string|Object_ }

    type of value [required]

  - **return**:  { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L350" target="_blank"><b>writeArray (arr = [], opts = {})</b></a>
    Write an array of data.

  - **param**: `arr` { _Array=[]_ }

    Array

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    length of array

  - **option**: `valueType` { _string|Object_ }

    type of array item

  - **return**:  { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L378" target="_blank"><b>writeObject (obj = {}, opts = {})</b></a>
    Write an object.

  - **param**: `obj` { _Object={}_ }

    object

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    size of object

  - **option**: `valueType` { _string|Object_ }

    type of object value

  - **return**:  { _number_ }

    length to write



### Decoder

- #### <a href="./src/Decoder.coffee?source#L20" target="_blank"><b>constructor (inputBlock)</b></a>
    constructor

  - **param**: `inputBlock` { _QueueBuffer_ }

    An QueueBuffer Object

- #### <a href="./src/Decoder.coffee?source#L30" target="_blank"><b>readFrom (inputBlock)</b></a>
    Reset data block

  - **param**: `inputBlock` { _QueueBuffer_ }

    An QueueBuffer Object

- #### <a href="./src/Decoder.coffee?source#L106" target="_blank"><b>readByte ()</b></a>
    Read a single byte.

  - **return**:  { _number_ }

    byte

- #### <a href="./src/Decoder.coffee?source#L113" target="_blank"><b>skipByte ()</b></a>
    Skip a single byte.

- #### <a href="./src/Decoder.coffee?source#L121" target="_blank"><b>readBoolean ()  <small>(alias: readBool)</small> </b></a>
    Read boolean value.

  - **return**:  { _Boolean_ }

    boolean value

- #### <a href="./src/Decoder.coffee?source#L130" target="_blank"><b>skipBoolean ()  <small>(alias: skipBool)</small> </b></a>
    skip a boolean value.

- #### <a href="./src/Decoder.coffee?source#L155" target="_blank"><b>readUInt (opts = {})  <small>(alias: readLength, readSign)</small> </b></a>
    Read an unsigned integer.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **return**:  { _number|string_ }

    integer, string for big integer

- #### <a href="./src/Decoder.coffee?source#L193" target="_blank"><b>skipUInt (opts = {})  <small>(alias: skipLength, skipSign)</small> </b></a>
    Skip an unsigned integer.

  - **param**: `opts` { _Object={}_ }

    options (see readUint)

- #### <a href="./src/Decoder.coffee?source#L216" target="_blank"><b>readInt (opts = {})  <small>(alias: readLong)</small> </b></a>
    Read an signed integer.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **return**:  { _number|string_ }

    integer, string for big integer

- #### <a href="./src/Decoder.coffee?source#L229" target="_blank"><b>skipInt (opts = {})  <small>(alias: skipLong)</small> </b></a>
    Skip a signed integer.

  - **param**: `opts` { _Object={}_ }

    options(see readInt)

- #### <a href="./src/Decoder.coffee?source#L238" target="_blank"><b>readFloat ()</b></a>
    Read a float.

  - **return**:  { _Number_ }

    float number

- #### <a href="./src/Decoder.coffee?source#L245" target="_blank"><b>skipFloat ()</b></a>
    Skip a float.

- #### <a href="./src/Decoder.coffee?source#L252" target="_blank"><b>readDouble ()</b></a>
    Read a double.

  - **return**:  { _number_ }

    double number

- #### <a href="./src/Decoder.coffee?source#L259" target="_blank"><b>skipDouble ()</b></a>
    Skip a double.

- #### <a href="./src/Decoder.coffee?source#L268" target="_blank"><b>readBytes (opts = {})</b></a>
    Read bytes.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    number of bytes

  - **return**:  { _Buffer_ }

    bytes

- #### <a href="./src/Decoder.coffee?source#L281" target="_blank"><b>skipBytes (opts = {})</b></a>
    Skip bytes

  - **param**: `opts` { _Object={}_ }

    options(see readBytes)

- #### <a href="./src/Decoder.coffee?source#L291" target="_blank"><b>readString (opts = {})</b></a>
    Read a string.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    byte length of string

  - **return**:  { _string_ }

    string

- #### <a href="./src/Decoder.coffee?source#L299" target="_blank"><b>skipString (opts = {})</b></a>
    Skip a string.

  - **param**: `opts` { _Object={}_ }

    options(see readString)

- #### <a href="./src/Decoder.coffee?source#L309" target="_blank"><b>readMap (opts = {})</b></a>
    Read a map.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    size of map

  - **option**: `keyType` { _string|Object_ }

    type of key[required]

  - **option**: `valueType` { _string|Object_ }

    type of value[required]

  - **return**:  { _Map(es6)|Object(else)_ }

    map

- #### <a href="./src/Decoder.coffee?source#L340" target="_blank"><b>skipMap (opts = {})</b></a>
    Skip a map.

  - **param**: `opts` { _Object={}_ }

    options(see readMap)

- #### <a href="./src/Decoder.coffee?source#L361" target="_blank"><b>readArray (opts = {})</b></a>
    Read an array.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    length of array

  - **option**: `valueType` { _string|Object_ }

    type of array item

  - **return**:  { _Array_ }

    array

- #### <a href="./src/Decoder.coffee?source#L384" target="_blank"><b>skipArray (opts = {})</b></a>
    Skip an array.

  - **param**: `opts` { _Object={}_ }

    options(see readArray)

- #### <a href="./src/Decoder.coffee?source#L403" target="_blank"><b>readObject (opts = {})</b></a>
    Read an object.

  - **param**: `opts` { _Object={}_ }

    options

  - **option**: `length` { _number_ }

    size of object

  - **option**: `valueType` { _string|Object_ }

    type of object value

  - **return**:  { _Object_ }

    object

- #### <a href="./src/Decoder.coffee?source#L426" target="_blank"><b>skipObject (opts = {})</b></a>
    Skip an array.

  - **param**: `opts` { _Object={}_ }

    options(see readObject)



## Test
```
npm test
```

## TODO
- Record type

## License
MIT@Jingchen Zhao
