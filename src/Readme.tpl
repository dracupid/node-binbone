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
<%= api %>

## Test
```
npm test
```

## TODO
- Record type

## License
MIT@Jingchen Zhao
