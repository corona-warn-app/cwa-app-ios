// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: internal/submission_payload.proto
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

struct SAP_Internal_SubmissionPayload {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var keys: [SAP_External_Exposurenotification_TemporaryExposureKey] = []

  var requestPadding: Data {
    get {return _requestPadding ?? Data()}
    set {_requestPadding = newValue}
  }
  /// Returns true if `requestPadding` has been explicitly set.
  var hasRequestPadding: Bool {return self._requestPadding != nil}
  /// Clears the value of `requestPadding`. Subsequent reads from it will return its default value.
  mutating func clearRequestPadding() {self._requestPadding = nil}

  var visitedCountries: [String] = []

  var origin: String {
    get {return _origin ?? String()}
    set {_origin = newValue}
  }
  /// Returns true if `origin` has been explicitly set.
  var hasOrigin: Bool {return self._origin != nil}
  /// Clears the value of `origin`. Subsequent reads from it will return its default value.
  mutating func clearOrigin() {self._origin = nil}

  var consentToFederation: Bool {
    get {return _consentToFederation ?? false}
    set {_consentToFederation = newValue}
  }
  /// Returns true if `consentToFederation` has been explicitly set.
  var hasConsentToFederation: Bool {return self._consentToFederation != nil}
  /// Clears the value of `consentToFederation`. Subsequent reads from it will return its default value.
  mutating func clearConsentToFederation() {self._consentToFederation = nil}

  var checkIns: [SAP_Internal_Pt_CheckIn] = []

  var submissionType: SAP_Internal_SubmissionPayload.SubmissionType {
    get {return _submissionType ?? .pcrTest}
    set {_submissionType = newValue}
  }
  /// Returns true if `submissionType` has been explicitly set.
  var hasSubmissionType: Bool {return self._submissionType != nil}
  /// Clears the value of `submissionType`. Subsequent reads from it will return its default value.
  mutating func clearSubmissionType() {self._submissionType = nil}

  var checkInProtectedReports: [SAP_Internal_Pt_CheckInProtectedReport] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum SubmissionType: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case pcrTest // = 0
    case rapidTest // = 1
    case hostWarning // = 2
    case srsSelfTest // = 3
    case srsRegisteredRat // = 4
    case srsUnregisteredRat // = 5
    case srsRegisteredPcr // = 6
    case srsUnregisteredPcr // = 7
    case srsRapidPcr // = 8
    case srsOther // = 9

    init() {
      self = .pcrTest
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .pcrTest
      case 1: self = .rapidTest
      case 2: self = .hostWarning
      case 3: self = .srsSelfTest
      case 4: self = .srsRegisteredRat
      case 5: self = .srsUnregisteredRat
      case 6: self = .srsRegisteredPcr
      case 7: self = .srsUnregisteredPcr
      case 8: self = .srsRapidPcr
      case 9: self = .srsOther
      default: return nil
      }
    }

    var rawValue: Int {
      switch self {
      case .pcrTest: return 0
      case .rapidTest: return 1
      case .hostWarning: return 2
      case .srsSelfTest: return 3
      case .srsRegisteredRat: return 4
      case .srsUnregisteredRat: return 5
      case .srsRegisteredPcr: return 6
      case .srsUnregisteredPcr: return 7
      case .srsRapidPcr: return 8
      case .srsOther: return 9
      }
    }

  }

  init() {}

  fileprivate var _requestPadding: Data? = nil
  fileprivate var _origin: String? = nil
  fileprivate var _consentToFederation: Bool? = nil
  fileprivate var _submissionType: SAP_Internal_SubmissionPayload.SubmissionType? = nil
}

#if swift(>=4.2)

extension SAP_Internal_SubmissionPayload.SubmissionType: CaseIterable {
  // Support synthesized by the compiler.
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension SAP_Internal_SubmissionPayload: @unchecked Sendable {}
extension SAP_Internal_SubmissionPayload.SubmissionType: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "SAP.internal"

extension SAP_Internal_SubmissionPayload: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SubmissionPayload"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "keys"),
    2: .same(proto: "requestPadding"),
    3: .same(proto: "visitedCountries"),
    4: .same(proto: "origin"),
    5: .same(proto: "consentToFederation"),
    6: .same(proto: "checkIns"),
    7: .same(proto: "submissionType"),
    8: .same(proto: "checkInProtectedReports"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.keys) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self._requestPadding) }()
      case 3: try { try decoder.decodeRepeatedStringField(value: &self.visitedCountries) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self._origin) }()
      case 5: try { try decoder.decodeSingularBoolField(value: &self._consentToFederation) }()
      case 6: try { try decoder.decodeRepeatedMessageField(value: &self.checkIns) }()
      case 7: try { try decoder.decodeSingularEnumField(value: &self._submissionType) }()
      case 8: try { try decoder.decodeRepeatedMessageField(value: &self.checkInProtectedReports) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.keys.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.keys, fieldNumber: 1)
    }
    try { if let v = self._requestPadding {
      try visitor.visitSingularBytesField(value: v, fieldNumber: 2)
    } }()
    if !self.visitedCountries.isEmpty {
      try visitor.visitRepeatedStringField(value: self.visitedCountries, fieldNumber: 3)
    }
    try { if let v = self._origin {
      try visitor.visitSingularStringField(value: v, fieldNumber: 4)
    } }()
    try { if let v = self._consentToFederation {
      try visitor.visitSingularBoolField(value: v, fieldNumber: 5)
    } }()
    if !self.checkIns.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.checkIns, fieldNumber: 6)
    }
    try { if let v = self._submissionType {
      try visitor.visitSingularEnumField(value: v, fieldNumber: 7)
    } }()
    if !self.checkInProtectedReports.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.checkInProtectedReports, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_Internal_SubmissionPayload, rhs: SAP_Internal_SubmissionPayload) -> Bool {
    if lhs.keys != rhs.keys {return false}
    if lhs._requestPadding != rhs._requestPadding {return false}
    if lhs.visitedCountries != rhs.visitedCountries {return false}
    if lhs._origin != rhs._origin {return false}
    if lhs._consentToFederation != rhs._consentToFederation {return false}
    if lhs.checkIns != rhs.checkIns {return false}
    if lhs._submissionType != rhs._submissionType {return false}
    if lhs.checkInProtectedReports != rhs.checkInProtectedReports {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SAP_Internal_SubmissionPayload.SubmissionType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "SUBMISSION_TYPE_PCR_TEST"),
    1: .same(proto: "SUBMISSION_TYPE_RAPID_TEST"),
    2: .same(proto: "SUBMISSION_TYPE_HOST_WARNING"),
    3: .same(proto: "SUBMISSION_TYPE_SRS_SELF_TEST"),
    4: .same(proto: "SUBMISSION_TYPE_SRS_REGISTERED_RAT"),
    5: .same(proto: "SUBMISSION_TYPE_SRS_UNREGISTERED_RAT"),
    6: .same(proto: "SUBMISSION_TYPE_SRS_REGISTERED_PCR"),
    7: .same(proto: "SUBMISSION_TYPE_SRS_UNREGISTERED_PCR"),
    8: .same(proto: "SUBMISSION_TYPE_SRS_RAPID_PCR"),
    9: .same(proto: "SUBMISSION_TYPE_SRS_OTHER"),
  ]
}
