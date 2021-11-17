// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: external/exposurenotification/temporary_exposure_key_signature_list.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

/// This file is auto-generated, DO NOT make any changes here
///https://static.googleusercontent.com/media/www.google.com/en//covid19/exposurenotifications/pdfs/Exposure-Key-File-Format-and-Verification.pdf

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

struct SAP_External_Exposurenotification_TEKSignatureList {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Information about associated signatures.
  var signatures: [SAP_External_Exposurenotification_TEKSignature] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SAP_External_Exposurenotification_TEKSignature {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Information to uniquely identify the public key associated
  /// with the EN server's signing key.
  var signatureInfo: SAP_External_Exposurenotification_SignatureInfo {
    get {return _signatureInfo ?? SAP_External_Exposurenotification_SignatureInfo()}
    set {_signatureInfo = newValue}
  }
  /// Returns true if `signatureInfo` has been explicitly set.
  var hasSignatureInfo: Bool {return self._signatureInfo != nil}
  /// Clears the value of `signatureInfo`. Subsequent reads from it will return its default value.
  mutating func clearSignatureInfo() {self._signatureInfo = nil}

  /// Reserved for future use. Both batch_num and batch_size
  /// must be set to a value of 1.
  var batchNum: Int32 {
    get {return _batchNum ?? 0}
    set {_batchNum = newValue}
  }
  /// Returns true if `batchNum` has been explicitly set.
  var hasBatchNum: Bool {return self._batchNum != nil}
  /// Clears the value of `batchNum`. Subsequent reads from it will return its default value.
  mutating func clearBatchNum() {self._batchNum = nil}

  var batchSize: Int32 {
    get {return _batchSize ?? 0}
    set {_batchSize = newValue}
  }
  /// Returns true if `batchSize` has been explicitly set.
  var hasBatchSize: Bool {return self._batchSize != nil}
  /// Clears the value of `batchSize`. Subsequent reads from it will return its default value.
  mutating func clearBatchSize() {self._batchSize = nil}

  /// Signature in X9.62 format (ASN.1 SEQUENCE of two INTEGER fields).
  var signature: Data {
    get {return _signature ?? Data()}
    set {_signature = newValue}
  }
  /// Returns true if `signature` has been explicitly set.
  var hasSignature: Bool {return self._signature != nil}
  /// Clears the value of `signature`. Subsequent reads from it will return its default value.
  mutating func clearSignature() {self._signature = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _signatureInfo: SAP_External_Exposurenotification_SignatureInfo? = nil
  fileprivate var _batchNum: Int32? = nil
  fileprivate var _batchSize: Int32? = nil
  fileprivate var _signature: Data? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "SAP.external.exposurenotification"

extension SAP_External_Exposurenotification_TEKSignatureList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TEKSignatureList"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "signatures"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.signatures) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.signatures.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.signatures, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_External_Exposurenotification_TEKSignatureList, rhs: SAP_External_Exposurenotification_TEKSignatureList) -> Bool {
    if lhs.signatures != rhs.signatures {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SAP_External_Exposurenotification_TEKSignature: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TEKSignature"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "signature_info"),
    2: .standard(proto: "batch_num"),
    3: .standard(proto: "batch_size"),
    4: .same(proto: "signature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._signatureInfo) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self._batchNum) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self._batchSize) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self._signature) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._signatureInfo {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if let v = self._batchNum {
      try visitor.visitSingularInt32Field(value: v, fieldNumber: 2)
    }
    if let v = self._batchSize {
      try visitor.visitSingularInt32Field(value: v, fieldNumber: 3)
    }
    if let v = self._signature {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_External_Exposurenotification_TEKSignature, rhs: SAP_External_Exposurenotification_TEKSignature) -> Bool {
    if lhs._signatureInfo != rhs._signatureInfo {return false}
    if lhs._batchNum != rhs._batchNum {return false}
    if lhs._batchSize != rhs._batchSize {return false}
    if lhs._signature != rhs._signature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
