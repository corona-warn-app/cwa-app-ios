// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: internal/ppdd/tri_state_boolean.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

/// This file is auto-generated, DO NOT make any changes here

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum SAP_Internal_Ppdd_TriStateBoolean: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case tsbUnspecified // = 0
  case tsbTrue // = 1
  case tsbFalse // = 2
  case UNRECOGNIZED(Int)

  init() {
    self = .tsbUnspecified
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .tsbUnspecified
    case 1: self = .tsbTrue
    case 2: self = .tsbFalse
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .tsbUnspecified: return 0
    case .tsbTrue: return 1
    case .tsbFalse: return 2
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension SAP_Internal_Ppdd_TriStateBoolean: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [SAP_Internal_Ppdd_TriStateBoolean] = [
    .tsbUnspecified,
    .tsbTrue,
    .tsbFalse,
  ]
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension SAP_Internal_Ppdd_TriStateBoolean: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension SAP_Internal_Ppdd_TriStateBoolean: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "TSB_UNSPECIFIED"),
    1: .same(proto: "TSB_TRUE"),
    2: .same(proto: "TSB_FALSE"),
  ]
}
