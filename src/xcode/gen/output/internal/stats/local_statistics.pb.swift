// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: internal/stats/local_statistics.proto
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

struct SAP_Internal_Stats_LocalStatistics {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var federalStateData: [SAP_Internal_Stats_FederalStateData] = []

  var administrativeUnitData: [SAP_Internal_Stats_AdministrativeUnitData] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct SAP_Internal_Stats_FederalStateData {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var federalState: SAP_Internal_Stats_FederalStateData.FederalState = .sh

  var updatedAt: Int64 = 0

  var sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData {
    get {return _sevenDayIncidence ?? SAP_Internal_Stats_SevenDayIncidenceData()}
    set {_sevenDayIncidence = newValue}
  }
  /// Returns true if `sevenDayIncidence` has been explicitly set.
  var hasSevenDayIncidence: Bool {return self._sevenDayIncidence != nil}
  /// Clears the value of `sevenDayIncidence`. Subsequent reads from it will return its default value.
  mutating func clearSevenDayIncidence() {self._sevenDayIncidence = nil}

  var sevenDayHospitalizationIncidenceUpdatedAt: Int64 = 0

  var sevenDayHospitalizationIncidence: SAP_Internal_Stats_SevenDayIncidenceData {
    get {return _sevenDayHospitalizationIncidence ?? SAP_Internal_Stats_SevenDayIncidenceData()}
    set {_sevenDayHospitalizationIncidence = newValue}
  }
  /// Returns true if `sevenDayHospitalizationIncidence` has been explicitly set.
  var hasSevenDayHospitalizationIncidence: Bool {return self._sevenDayHospitalizationIncidence != nil}
  /// Clears the value of `sevenDayHospitalizationIncidence`. Subsequent reads from it will return its default value.
  mutating func clearSevenDayHospitalizationIncidence() {self._sevenDayHospitalizationIncidence = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum FederalState: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case sh // = 0
    case hh // = 1
    case ni // = 2
    case hb // = 3
    case nrw // = 4
    case he // = 5
    case rp // = 6
    case bw // = 7
    case by // = 8
    case sl // = 9
    case be // = 10
    case bb // = 11
    case mv // = 12
    case sn // = 13
    case st // = 14
    case th // = 15
    case UNRECOGNIZED(Int)

    init() {
      self = .sh
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .sh
      case 1: self = .hh
      case 2: self = .ni
      case 3: self = .hb
      case 4: self = .nrw
      case 5: self = .he
      case 6: self = .rp
      case 7: self = .bw
      case 8: self = .by
      case 9: self = .sl
      case 10: self = .be
      case 11: self = .bb
      case 12: self = .mv
      case 13: self = .sn
      case 14: self = .st
      case 15: self = .th
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .sh: return 0
      case .hh: return 1
      case .ni: return 2
      case .hb: return 3
      case .nrw: return 4
      case .he: return 5
      case .rp: return 6
      case .bw: return 7
      case .by: return 8
      case .sl: return 9
      case .be: return 10
      case .bb: return 11
      case .mv: return 12
      case .sn: return 13
      case .st: return 14
      case .th: return 15
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}

  fileprivate var _sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData? = nil
  fileprivate var _sevenDayHospitalizationIncidence: SAP_Internal_Stats_SevenDayIncidenceData? = nil
}

#if swift(>=4.2)

extension SAP_Internal_Stats_FederalStateData.FederalState: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [SAP_Internal_Stats_FederalStateData.FederalState] = [
    .sh,
    .hh,
    .ni,
    .hb,
    .nrw,
    .he,
    .rp,
    .bw,
    .by,
    .sl,
    .be,
    .bb,
    .mv,
    .sn,
    .st,
    .th,
  ]
}

#endif  // swift(>=4.2)

struct SAP_Internal_Stats_AdministrativeUnitData {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var administrativeUnitShortID: UInt32 = 0

  var updatedAt: Int64 = 0

  var sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData {
    get {return _sevenDayIncidence ?? SAP_Internal_Stats_SevenDayIncidenceData()}
    set {_sevenDayIncidence = newValue}
  }
  /// Returns true if `sevenDayIncidence` has been explicitly set.
  var hasSevenDayIncidence: Bool {return self._sevenDayIncidence != nil}
  /// Clears the value of `sevenDayIncidence`. Subsequent reads from it will return its default value.
  mutating func clearSevenDayIncidence() {self._sevenDayIncidence = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData? = nil
}

struct SAP_Internal_Stats_SevenDayIncidenceData {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var value: Double = 0

  var trend: SAP_Internal_Stats_KeyFigure.Trend = .unspecifiedTrend

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "SAP.internal.stats"

extension SAP_Internal_Stats_LocalStatistics: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".LocalStatistics"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "federalStateData"),
    2: .same(proto: "administrativeUnitData"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.federalStateData) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.administrativeUnitData) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.federalStateData.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.federalStateData, fieldNumber: 1)
    }
    if !self.administrativeUnitData.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.administrativeUnitData, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_Internal_Stats_LocalStatistics, rhs: SAP_Internal_Stats_LocalStatistics) -> Bool {
    if lhs.federalStateData != rhs.federalStateData {return false}
    if lhs.administrativeUnitData != rhs.administrativeUnitData {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SAP_Internal_Stats_FederalStateData: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".FederalStateData"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "federalState"),
    2: .same(proto: "updatedAt"),
    3: .same(proto: "sevenDayIncidence"),
    4: .same(proto: "sevenDayHospitalizationIncidenceUpdatedAt"),
    5: .same(proto: "sevenDayHospitalizationIncidence"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.federalState) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.updatedAt) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._sevenDayIncidence) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.sevenDayHospitalizationIncidenceUpdatedAt) }()
      case 5: try { try decoder.decodeSingularMessageField(value: &self._sevenDayHospitalizationIncidence) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.federalState != .sh {
      try visitor.visitSingularEnumField(value: self.federalState, fieldNumber: 1)
    }
    if self.updatedAt != 0 {
      try visitor.visitSingularInt64Field(value: self.updatedAt, fieldNumber: 2)
    }
    try { if let v = self._sevenDayIncidence {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if self.sevenDayHospitalizationIncidenceUpdatedAt != 0 {
      try visitor.visitSingularInt64Field(value: self.sevenDayHospitalizationIncidenceUpdatedAt, fieldNumber: 4)
    }
    try { if let v = self._sevenDayHospitalizationIncidence {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_Internal_Stats_FederalStateData, rhs: SAP_Internal_Stats_FederalStateData) -> Bool {
    if lhs.federalState != rhs.federalState {return false}
    if lhs.updatedAt != rhs.updatedAt {return false}
    if lhs._sevenDayIncidence != rhs._sevenDayIncidence {return false}
    if lhs.sevenDayHospitalizationIncidenceUpdatedAt != rhs.sevenDayHospitalizationIncidenceUpdatedAt {return false}
    if lhs._sevenDayHospitalizationIncidence != rhs._sevenDayHospitalizationIncidence {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SAP_Internal_Stats_FederalStateData.FederalState: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "FEDERAL_STATE_SH"),
    1: .same(proto: "FEDERAL_STATE_HH"),
    2: .same(proto: "FEDERAL_STATE_NI"),
    3: .same(proto: "FEDERAL_STATE_HB"),
    4: .same(proto: "FEDERAL_STATE_NRW"),
    5: .same(proto: "FEDERAL_STATE_HE"),
    6: .same(proto: "FEDERAL_STATE_RP"),
    7: .same(proto: "FEDERAL_STATE_BW"),
    8: .same(proto: "FEDERAL_STATE_BY"),
    9: .same(proto: "FEDERAL_STATE_SL"),
    10: .same(proto: "FEDERAL_STATE_BE"),
    11: .same(proto: "FEDERAL_STATE_BB"),
    12: .same(proto: "FEDERAL_STATE_MV"),
    13: .same(proto: "FEDERAL_STATE_SN"),
    14: .same(proto: "FEDERAL_STATE_ST"),
    15: .same(proto: "FEDERAL_STATE_TH"),
  ]
}

extension SAP_Internal_Stats_AdministrativeUnitData: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".AdministrativeUnitData"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "administrativeUnitShortId"),
    2: .same(proto: "updatedAt"),
    3: .same(proto: "sevenDayIncidence"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self.administrativeUnitShortID) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.updatedAt) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._sevenDayIncidence) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.administrativeUnitShortID != 0 {
      try visitor.visitSingularUInt32Field(value: self.administrativeUnitShortID, fieldNumber: 1)
    }
    if self.updatedAt != 0 {
      try visitor.visitSingularInt64Field(value: self.updatedAt, fieldNumber: 2)
    }
    try { if let v = self._sevenDayIncidence {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_Internal_Stats_AdministrativeUnitData, rhs: SAP_Internal_Stats_AdministrativeUnitData) -> Bool {
    if lhs.administrativeUnitShortID != rhs.administrativeUnitShortID {return false}
    if lhs.updatedAt != rhs.updatedAt {return false}
    if lhs._sevenDayIncidence != rhs._sevenDayIncidence {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension SAP_Internal_Stats_SevenDayIncidenceData: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SevenDayIncidenceData"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "value"),
    2: .same(proto: "trend"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.value) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.trend) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.value != 0 {
      try visitor.visitSingularDoubleField(value: self.value, fieldNumber: 1)
    }
    if self.trend != .unspecifiedTrend {
      try visitor.visitSingularEnumField(value: self.trend, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_Internal_Stats_SevenDayIncidenceData, rhs: SAP_Internal_Stats_SevenDayIncidenceData) -> Bool {
    if lhs.value != rhs.value {return false}
    if lhs.trend != rhs.trend {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
