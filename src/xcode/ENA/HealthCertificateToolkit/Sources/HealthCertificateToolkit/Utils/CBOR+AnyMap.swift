//
// 🦠 Corona-Warn-App
//

import SwiftCBOR

extension Dictionary where Key == CBOR, Value == CBOR {

    var anyMap: [String: Any?] {
        var anyMap = [String: Any?]()
        for (key, value) in self {
            guard case let .utf8String(stringKey) = key else {
                fatalError("String key expected: \(self)")
            }
            anyMap[stringKey] = value.anyValue
        }
        return anyMap
    }
}

extension CBOR {

    var anyValue: Any? {
        switch self {
        case .boolean(let boolValue):
            return boolValue as Any
        case .unsignedInt(let uIntValue):
            return Int(uIntValue) as Any
        case .negativeInt(let negativeIntValue):
            return -Int(negativeIntValue) - 1 as Any
        case .double(let doubleValue):
            return doubleValue as Any
        case .float(let floatValue):
            return floatValue as Any
        case .half(let halfValue):
            return halfValue as Any
        case .simple(let simpleValue):
            return simpleValue as Any
        case .byteString(let byteStringValue):
            return byteStringValue as Any
        case .date(let dateValue):
            return dateValue as Any
        case .utf8String(let stringValue):
            return stringValue as Any
        case .array(let arrayValue):
            return arrayValue.map { $0.anyValue }
        case .map(let mapValue):
            return mapValue.anyMap as Any
        case .null, .undefined:
            return nil as Any?
        default:
            return nil as Any?
        }
    }
}
