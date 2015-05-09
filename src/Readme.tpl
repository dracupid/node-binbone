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
<%= api %>

## Test
```
npm test
```

## TODO
- Record type

## License
MIT@Dracupid
