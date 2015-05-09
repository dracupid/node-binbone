Dirk
=================
A binary encode specification aimed at achieving optimal space utilization, inspired by Apache Avro™, Protocol Buffers and more.

* Auther: Zhao Jingchen
* Version: 0.0.1

> **This is not a complete data serialization specification.**
This document defines ___dirk___ and its basic ideas.

## 1. Types

#### 1.1 Basic Type
- __byte__: An 8-bit byte, the smallest encoding unit of data.

#### 1.2 Primitive Types
- __boolean__: A binary value
    + Encoded as a single byte, either ___0___ (false) or ___1___ (true).

- __uInt__: An unsigned integer
    + Encoded using [variable-length coding(vInt)](http://lucene.apache.org/core/3_5_0/fileformats.html#VInt).
    + Can be any longer, big integers should be well processed.

> vInt is a method of serializing integers using one or more bytes. Smaller numbers take a smaller number of bytes.<br>
> The first bit of each byte indicates whether more bytes remain to be read. The low-order seven bits are used to store integer value.

- __int__: An signed integer
    + Encoded using [zig-zag](https://developers.google.com/protocol-buffers/docs/encoding?csw=1#types) coding first, and then treated as an __uInt__.

> Zig-zag encoding maps signed integers to unsigned integers so that numbers with a small absolute value have a small encoded value too.<br>
> -1 --> 01, 1 --> 02, -2 --> 03, and so on.

- __float__: Single precision (32-bit) [IEEE 754](http://en.wikipedia.org/wiki/IEEE_floating_point) floating-point number
    + Encoded according to IEEE 754 in big-endian format as 4 bytes.

- __double__: Double precision (64-bit) [IEEE 754](http://en.wikipedia.org/wiki/IEEE_floating_point) floating-point number
    + Encoded according to IEEE 754 in big-endian format as 8 bytes.

- __bytes__: Sequence of bytes
    + Encoded as an __uInt__ followed by that many bytes of data.

- __string__: Sequence of UTF-8 characters
    + Encoded as an __uInt__ followed by that many bytes (not string length) of UTF-8 characters.

#### 1.3 Complex Types
Complex Type is combined with primitive types.

- __Map__: A key-value data structure.
    + options:
        * [required] keyType: map keys' type.
        * [required] valueType: map values' type.
    + Encoded as an __uInt__ followed by that many key/value pairs.

- __Object__: A special __Map__ using string as the key, and values may be of more than one types.
    + options:
        * [not recommended] valueType: object values' type. If you really want to use a single type, please use __Map__.
    + Encoded as an __uInt__ followed by that many string/value pairs.
    + Object with a `valueType` option is an alternative of `<string, type>` __Map__.

- __Array__: Sequence of values.
    + option:
        * [recommended] valueType: type (with necessary options) of the items in the array.
    + Encoded as an __uInt__ followed by that many array items.
    + Array is a special __Map__ which use sequence index as the indicated key.

- __Record__: Fixed-length sequence of values whose types are determined.
    + options:
        * [required] fields: elements' type definitions, additional element names can be set.
    + Encoded by encoding the values of its fields in the order declared.
    + If element name is set, __Record__ is an object whose keys and types are determined.
    + If element name is absent, __Record__ is an multi-type array whose size and types are determined.

#### 1.4 Fixed-Length Types
If `length` option is set for follow types, they will use a fixed-length alternative to encode these types.

- __int__, __uInt__
    + _length_: desired byte length of a integer. Length can only be 1, 2, 4, 8, or an error should be produced.
    + Encoded as that many bytes in big-endian format.

- __bytes__
    + _length_: length of bytes. If this options is not equal to input bytes' length, an error should be produced.
    + Encoded as that many bytes of data.

- __string__
    + _length_: byte length of the string. If this options is not equal to input __string__'s byte length, an error should be produced.
    + Encoded as that many **bytes**(not string length) of UTF-8 encoded characters.

- __Map__, __Object__, __Array__:
    + _length_: number of the items. If this options is not equal to the length of input data, an error should be produced.
    + Encoded without the __uInt__ length value.

#### 1.5 Variable Types (optional for encoder)
If `valueType` option of __Object__, __Array__ is absent, type is inferred by encoder, and type ID is encoded before the data.

- Types with `length` option, except __int__ and __uInt__, cannot be inferred.
- Variable types are not recommended to be over used.

Besides, only following types are allowed to be inferred.
##### Type ID
- 0x01: byte
- 0x02: boolean
- 0x03: uInt
    + 0x13-uInt8, 0x23-uInt16, 0x43-uInt32, 0x83-uInt64
- 0x04: int
    + 0x14-int8, 0x24-int16, 0x44-int32, 0x84-int64
- 0x05: float
- 0x06: double
- 0x07: bytes
- 0x08: string
- 0x0A: Object
- 0x0B: Array (without specific type)
- 0x1BXX: Array, XX is array items' typeID

## 2. Default type values and null
No null value or null type is specificed, null value will be encoded as default type value.

| type | default |
|-------|--------|
| byte | 0x00 |
| boolean | false |
| int, uInt, float, double | 0 |
| bytes, string, Map, Object, Array | 0x00 (empty) |
| Record | every field is default value |
