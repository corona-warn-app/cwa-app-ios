//
// 🦠 Corona-Warn-App
//

import SwiftCBOR

extension Dictionary where Key == CBOR, Value == CBOR {
    var cborMapWithTrimmingWhiteSpaces: [CBOR: CBOR] {
        var anyMap = [CBOR: CBOR]()
        for (key, value) in self {
            anyMap[key] = value.cborValue
        }
        return anyMap
    }
}

extension CBOR {

    var cborValue: CBOR? {
        switch self {
        case .utf8String(let stringValue):
            let trimmedString = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            return CBOR(stringLiteral: trimmedString)
            
        case .map(let cborDictionary):
            let trimmedDictionary = cborDictionary.cborMapWithTrimmingWhiteSpaces
            return .map(trimmedDictionary)
            
        case .array(let arrayValue):
            let trimmedArray = arrayValue.compactMap { $0.cborValue }
            return .array(trimmedArray)
            
        case .null:
            // if the value is null we will remove both the key and value from the dictionary
            return nil
            
        default:
            return self
        }
    }
}
