SIGN =
    byte: 0x01
    boolean: 0x02
    uInt: 0x03
    int: 0x04
    float: 0x05
    double: 0x06
    bytes: 0x07
    string: 0x08
    object: 0x0A
    array: 0x0B

module.exports.SIGN = SIGN
module.exports.RSIGN = do ->
    res = {}
    for k, v of SIGN
        res[v] = k
    res

###
    0x03: uInt
      + 0x13-uInt8, 0x23-uInt16, 0x33-uInt32, 0x43-uInt64
    0x04: int
      + 0x14-int8, 0x24-int16, 0x34-int32, 0x44-int64
###
