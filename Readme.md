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

## API


- #### <a href="./src/Encoder.coffee?source#L35" target="_blank"><b>constructor(outputBlock)</b></a>
  constructor

  - **<u>param</u>**: `outputBlock` { _Block_ }

    An DirkBlock Object

- #### <a href="./src/Encoder.coffee?source#L43" target="_blank"><b>writeTo(outputBlock)</b></a>
  Reset data block

  - **<u>param</u>**: `outputBlock` { _Block_ }

    see constructor

- #### <a href="./src/Encoder.coffee?source#L116" target="_blank"><b>writeByte(value = 0)</b></a>
  Write a byte.

  - **<u>param</u>**: `value` { _number=0_ }

    byte value

  - **<u>return</u>**: { _number_ }

    length to write (always 1)

- #### <a href="./src/Encoder.coffee?source#L126" target="_blank"><b>writeBoolean(value) (alias: writeBool) </b></a>
  Write a boolean value.

  - **<u>param</u>**: `value` { _boolean_ }

    boolean value

  - **<u>return</u>**: { _number_ }

    length to write (always 1)

- #### <a href="./src/Encoder.coffee?source#L162" target="_blank"><b>writeUInt(num = 0 | string, opts = {}) (alias: writeLength, writeSign) </b></a>
  Write an unsigned integer, using variable-length coding.

  - **<u>param</u>**: `num` { _number=0 | string_ }

    integer, use string for any big integer

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L193" target="_blank"><b>writeInt(opts = {}) (alias: writeLong) </b></a>
  Write an signed integer, using zig-zag variable-length coding.

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of integer (1, 2, 4, 8)

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L226" target="_blank"><b>writeFloat(value = 0)</b></a>
  Write a float.

  - **<u>param</u>**: `value` { _number=0_ }

    float point number

  - **<u>return</u>**: { _number_ }

    length to write (always 4)

- #### <a href="./src/Encoder.coffee?source#L235" target="_blank"><b>writeDouble(value = 0)</b></a>
  Write a double.

  - **<u>param</u>**: `value` { _number=0_ }

    float point number

  - **<u>return</u>**: { _number_ }

    length to write (always 8)

- #### <a href="./src/Encoder.coffee?source#L246" target="_blank"><b>writeBytes(values, opts = {})</b></a>
  Write bytes.

  - **<u>param</u>**: `values` { _Array | Buffer_ }

    bytes

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    number of bytes

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L267" target="_blank"><b>writeString(str, opts = {})</b></a>
  Write a string.

  - **<u>param</u>**: `str` { _string_ }

    string

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    byte length of string

  - **<u>return</u>**: { _number_ }

    length to write

- #### <a href="./src/Encoder.coffee?source#L288" target="_blank"><b>writeMap(map =  {}, opts = {})</b></a>
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

- #### <a href="./src/Encoder.coffee?source#L324" target="_blank"><b>writeArray(arr = [], opts = {})</b></a>
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

- #### <a href="./src/Encoder.coffee?source#L352" target="_blank"><b>writeObject(obj = {}, opts = {})</b></a>
  Write an object.

  - **<u>param</u>**: `obj` { _Object={}_ }

    object

  - **<u>param</u>**: `opts` { _Object={}_ }

    options

  - **<u>option</u>**: `length` { _number_ }

    length of array

  - **<u>option</u>**: `valueType` { _string|Object_ }

    type of object value

  - **<u>return</u>**: { _number_ }

    length to write



## Test
```
npm test
```


## License
MIT@Dracupid
