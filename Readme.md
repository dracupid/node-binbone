node-dirk
=================
Node.js(io.js) implemention of [Dirk](doc/spec.md), A binary encode specification aimed at achieving optimal space utilization.

[![NPM version](https://badge.fury.io/js/node-dirk.svg)](https://www.npmjs.com/package/node-dirk)
[![Deps](https://david-dm.org/dracupid/node-dirk.svg?style=flat)](https://david-dm.org/dracupid/node-dirk)
[![Build Status](https://travis-ci.org/dracupid/node-dirk.svg)](https://travis-ci.org/dracupid/node-dirk)
[![Build status](https://ci.appveyor.com/api/projects/status/github/dracupid/node-dirk?svg=true)](https://ci.appveyor.com/project/dracupid/node-dirk)

## Installation
```bash
npm i node-dirk -S
```

## Usage
- Use Block. Block can be use as both an encoder and a decoder.

```javascript
Block = require("dirk");
block = new Block(1024); // args are the same as a QueueBuffer

block.writeArray([1, 2, 3]);
block.writeUInt("123456789012345"); // Big integer(use [jsbn](https://github.com/andyperlitch/jsbn))
block.readArray();
block.readUInt();
```

- Use encoder/decoder.

Directly:

```javascript
Encoder = require("dirk").Encoder;
encodeBlock = new Encoder();

encodeBlock.writeInt(123);
```

Specify a Buffer for data:

```javascript
dirk = require('dirk');
buf = new dirk.QueueBuffer();
buf.writeUInt16BE(12);
decoder = new dirk.Decoder(buf);
decoder.readUInt({length: 2});
```

## API

### Encoder

- #### <a href="./src/Encoder.coffee?source#L46" target="_blank"><b>constructor(outputBlock)</b></a>
  constructor

  - **<u>param</u>**: `outputBlock` { _FlexBuffer_ }

    An DirkBlock Object

- #### <a href="./src/Encoder.coffee?source#L56" target="_blank"><b>writeTo(outputBlock)</b></a>
  Reset data block

  - **<u>param</u>**: `outputBlock` { _FlexBuffer_ }

    An DirkBlock Object

- #### <a href="./src/Encoder.coffee?source#L132" target="_blank"><b>writeByte(value = 0)</b></a>
  Write a byte.

  - **<u>param</u>**: `value` { _number=0_ }

    byte value

  - **<u>return</u>**: { _number_ }

    length to write (always 1)

- #### <a href="./src/Encoder.coffee?source#L142" target="_blank"><b>writeBoolean(value) (alias: writeBool) </b></a>
  Write a boolean value.

  - **<u>param</u>**: `value` { _boolean_ }

    boolean value

  - **<u>return</u>**: { _number_ }

    length to write (always 1)

- #### <a href="./src/Encoder.coffee?source#L181" target="_blank"><b>writeUInt(num = 0 | string, opts = {}) (alias: writeLength, writeSign) </b></a>
  Write an unsigned integer, using variable-length coding.

  - **<u>param</u>**: `num` { _number=0 | string_ }

    integer, use string for any big integer

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L214" target="_blank"><b>writeInt(opts = {}) (alias: writeLong) </b></a>
  Write an signed integer, using zig-zag variable-length coding.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L249" target="_blank"><b>writeFloat(value = 0)</b></a>
  Write a float.

  - **<u>param</u>**: `value` { _number=0_ }

    float point number

  - **<u>return</u>**: { _number_ }

    length to write (always 4)

- #### <a href="./src/Encoder.coffee?source#L258" target="_blank"><b>writeDouble(value = 0)</b></a>
  Write a double.

  - **<u>param</u>**: `value` { _number=0_ }

    float point number

  - **<u>return</u>**: { _number_ }

    length to write (always 8)

- #### <a href="./src/Encoder.coffee?source#L269" target="_blank"><b>writeBytes(values, opts = {})</b></a>
  Write bytes.

  - **<u>param</u>**: `values` { _Array | Buffer_ }

    bytes

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    number of bytes

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L290" target="_blank"><b>writeString(str, opts = {})</b></a>
  Write a string.

  - **<u>param</u>**: `str` { _string_ }

    string

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of string

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L311" target="_blank"><b>writeMap(map =  {}, opts = {})</b></a>
  Write a map.

  - **<u>param</u>**: `map` { _Object | Map = {}_ }

    key-value map

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    size of map

  - **<u>option</u>**: `keyType` { _string|Object_ }

    type of key[required]

  - **<u>option</u>**: `valueType` { _string|Object_ }

    type of value[required]

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L348" target="_blank"><b>writeArray(arr = [], opts = {})</b></a>
  Write an array of data.

  - **<u>param</u>**: `arr` { _Array=[]_ }

    Array

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    length of array

  - **<u>option</u>**: `valueType` { _string|Object_ }

    type of array item

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L376" target="_blank"><b>writeObject(obj = {}, opts = {})</b></a>
  Write an object.

  - **<u>param</u>**: `obj` { _Object={}_ }

    object

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    size of object

  - **<u>option</u>**: `valueType` { _string|Object_ }

    type of object value

  - **<u>return</u>**: { _number_ }

    length to write


### Decoder

- #### <a href="./src/Decoder.coffee?source#L18" target="_blank"><b>constructor(inputBlock)</b></a>
  constructor

  - **<u>param</u>**: `inputBlock` { _QueueBuffer_ }

    An QueueBuffer Object

- #### <a href="./src/Decoder.coffee?source#L28" target="_blank"><b>readFrom(inputBlock)</b></a>
  Reset data block

  - **<u>param</u>**: `inputBlock` { _QueueBuffer_ }

    An QueueBuffer Object

- #### <a href="./src/Decoder.coffee?source#L104" target="_blank"><b>readByte()</b></a>
  Read a single byte.

  - **<u>return</u>**: { _number_ }

    byte

- #### <a href="./src/Decoder.coffee?source#L111" target="_blank"><b>skipByte()</b></a>
  Skip a single byte.

- #### <a href="./src/Decoder.coffee?source#L119" target="_blank"><b>readBoolean() (alias: readBool) </b></a>
  Read boolean value.

  - **<u>return</u>**: { _Boolean_ }

    boolean value

- #### <a href="./src/Decoder.coffee?source#L128" target="_blank"><b>skipBoolean() (alias: skipBool) </b></a>
  skip a boolean value.

- #### <a href="./src/Decoder.coffee?source#L153" target="_blank"><b>readUInt(opts = {}) (alias: readLength, readSign) </b></a>
  Read an unsigned integer.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **<u>return</u>**: { _number|string_ }

    integer, string for big integer

- #### <a href="./src/Decoder.coffee?source#L191" target="_blank"><b>skipUInt(opts = {}) (alias: skipLength, skipSign) </b></a>
  Skip an unsigned integer.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options (see readUint)

- #### <a href="./src/Decoder.coffee?source#L214" target="_blank"><b>readInt(opts = {}) (alias: readLong) </b></a>
  Read an signed integer.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **<u>return</u>**: { _number|string_ }

    integer, string for big integer

- #### <a href="./src/Decoder.coffee?source#L227" target="_blank"><b>skipInt(opts = {}) (alias: skipLong) </b></a>
  Skip a signed integer.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options(see readInt)

- #### <a href="./src/Decoder.coffee?source#L236" target="_blank"><b>readFloat()</b></a>
  Read a float.

  - **<u>return</u>**: { _Number_ }

    float number

- #### <a href="./src/Decoder.coffee?source#L243" target="_blank"><b>skipFloat()</b></a>
  Skip a float.

- #### <a href="./src/Decoder.coffee?source#L250" target="_blank"><b>readDouble()</b></a>
  Read a double.

  - **<u>return</u>**: { _number_ }

    double number

- #### <a href="./src/Decoder.coffee?source#L257" target="_blank"><b>skipDouble()</b></a>
  Skip a double.

- #### <a href="./src/Decoder.coffee?source#L266" target="_blank"><b>readBytes(opts = {})</b></a>
  Read bytes.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    number of bytes

  - **<u>return</u>**: { _Buffer_ }

    bytes

- #### <a href="./src/Decoder.coffee?source#L279" target="_blank"><b>skipBytes(opts = {})</b></a>
  Skip bytes

  - **<u>param</u>**: `opts` { _Object={}_ }

    options(see readBytes)

- #### <a href="./src/Decoder.coffee?source#L289" target="_blank"><b>readString(opts = {})</b></a>
  Read a string.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of string

  - **<u>return</u>**: { _string_ }

    string

- #### <a href="./src/Decoder.coffee?source#L297" target="_blank"><b>skipString(opts = {})</b></a>
  Skip a string.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options(see readString)

- #### <a href="./src/Decoder.coffee?source#L307" target="_blank"><b>readMap(opts = {})</b></a>
  Read a map.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    size of map

  - **<u>option</u>**: `keyType` { _string|Object_ }

    type of key[required]

  - **<u>option</u>**: `valueType` { _string|Object_ }

    type of value[required]

  - **<u>return</u>**: { _Map(es6)|Object(else)_ }

    map

- #### <a href="./src/Decoder.coffee?source#L338" target="_blank"><b>skipMap(opts = {})</b></a>
  Skip a map.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options(see readMap)

- #### <a href="./src/Decoder.coffee?source#L359" target="_blank"><b>readArray(opts = {})</b></a>
  Read an array.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    length of array

  - **<u>option</u>**: `valueType` { _string|Object_ }

    type of array item

  - **<u>return</u>**: { _Array_ }

    array

- #### <a href="./src/Decoder.coffee?source#L382" target="_blank"><b>skipArray(opts = {})</b></a>
  Skip an array.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options(see readArray)

- #### <a href="./src/Decoder.coffee?source#L401" target="_blank"><b>readObject(opts = {})</b></a>
  Read an object.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    size of object

  - **<u>option</u>**: `valueType` { _string|Object_ }

    type of object value

  - **<u>return</u>**: { _Object_ }

    object

- #### <a href="./src/Decoder.coffee?source#L424" target="_blank"><b>skipObject(opts = {})</b></a>
  Skip an array.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options(see readObject)



## Test
```
npm test
```

## TODO
- Record type

## License
MIT@Dracupid
