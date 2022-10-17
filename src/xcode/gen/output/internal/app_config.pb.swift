// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: internal/app_config.proto
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

struct SAP_Internal_ApplicationConfiguration {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var minRiskScore: Int32 {
    get {return _storage._minRiskScore}
    set {_uniqueStorage()._minRiskScore = newValue}
  }

  var riskScoreClasses: SAP_Internal_RiskScoreClassification {
    get {return _storage._riskScoreClasses ?? SAP_Internal_RiskScoreClassification()}
    set {_uniqueStorage()._riskScoreClasses = newValue}
  }
  /// Returns true if `riskScoreClasses` has been explicitly set.
  var hasRiskScoreClasses: Bool {return _storage._riskScoreClasses != nil}
  /// Clears the value of `riskScoreClasses`. Subsequent reads from it will return its default value.
  mutating func clearRiskScoreClasses() {_uniqueStorage()._riskScoreClasses = nil}

  var exposureConfig: SAP_Internal_RiskScoreParameters {
    get {return _storage._exposureConfig ?? SAP_Internal_RiskScoreParameters()}
    set {_uniqueStorage()._exposureConfig = newValue}
  }
  /// Returns true if `exposureConfig` has been explicitly set.
  var hasExposureConfig: Bool {return _storage._exposureConfig != nil}
  /// Clears the value of `exposureConfig`. Subsequent reads from it will return its default value.
  mutating func clearExposureConfig() {_uniqueStorage()._exposureConfig = nil}

  var attenuationDuration: SAP_Internal_AttenuationDuration {
    get {return _storage._attenuationDuration ?? SAP_Internal_AttenuationDuration()}
    set {_uniqueStorage()._attenuationDuration = newValue}
  }
  /// Returns true if `attenuationDuration` has been explicitly set.
  var hasAttenuationDuration: Bool {return _storage._attenuationDuration != nil}
  /// Clears the value of `attenuationDuration`. Subsequent reads from it will return its default value.
  mutating func clearAttenuationDuration() {_uniqueStorage()._attenuationDuration = nil}

  var appVersion: SAP_Internal_ApplicationVersionConfiguration {
    get {return _storage._appVersion ?? SAP_Internal_ApplicationVersionConfiguration()}
    set {_uniqueStorage()._appVersion = newValue}
  }
  /// Returns true if `appVersion` has been explicitly set.
  var hasAppVersion: Bool {return _storage._appVersion != nil}
  /// Clears the value of `appVersion`. Subsequent reads from it will return its default value.
  mutating func clearAppVersion() {_uniqueStorage()._appVersion = nil}

  var appFeatures: SAP_Internal_AppFeatures {
    get {return _storage._appFeatures ?? SAP_Internal_AppFeatures()}
    set {_uniqueStorage()._appFeatures = newValue}
  }
  /// Returns true if `appFeatures` has been explicitly set.
  var hasAppFeatures: Bool {return _storage._appFeatures != nil}
  /// Clears the value of `appFeatures`. Subsequent reads from it will return its default value.
  mutating func clearAppFeatures() {_uniqueStorage()._appFeatures = nil}

  var supportedCountries: [String] {
    get {return _storage._supportedCountries}
    set {_uniqueStorage()._supportedCountries = newValue}
  }

  var iosKeyDownloadParameters: SAP_Internal_KeyDownloadParametersIOS {
    get {return _storage._iosKeyDownloadParameters ?? SAP_Internal_KeyDownloadParametersIOS()}
    set {_uniqueStorage()._iosKeyDownloadParameters = newValue}
  }
  /// Returns true if `iosKeyDownloadParameters` has been explicitly set.
  var hasIosKeyDownloadParameters: Bool {return _storage._iosKeyDownloadParameters != nil}
  /// Clears the value of `iosKeyDownloadParameters`. Subsequent reads from it will return its default value.
  mutating func clearIosKeyDownloadParameters() {_uniqueStorage()._iosKeyDownloadParameters = nil}

  var androidKeyDownloadParameters: SAP_Internal_KeyDownloadParametersAndroid {
    get {return _storage._androidKeyDownloadParameters ?? SAP_Internal_KeyDownloadParametersAndroid()}
    set {_uniqueStorage()._androidKeyDownloadParameters = newValue}
  }
  /// Returns true if `androidKeyDownloadParameters` has been explicitly set.
  var hasAndroidKeyDownloadParameters: Bool {return _storage._androidKeyDownloadParameters != nil}
  /// Clears the value of `androidKeyDownloadParameters`. Subsequent reads from it will return its default value.
  mutating func clearAndroidKeyDownloadParameters() {_uniqueStorage()._androidKeyDownloadParameters = nil}

  var iosExposureDetectionParameters: SAP_Internal_ExposureDetectionParametersIOS {
    get {return _storage._iosExposureDetectionParameters ?? SAP_Internal_ExposureDetectionParametersIOS()}
    set {_uniqueStorage()._iosExposureDetectionParameters = newValue}
  }
  /// Returns true if `iosExposureDetectionParameters` has been explicitly set.
  var hasIosExposureDetectionParameters: Bool {return _storage._iosExposureDetectionParameters != nil}
  /// Clears the value of `iosExposureDetectionParameters`. Subsequent reads from it will return its default value.
  mutating func clearIosExposureDetectionParameters() {_uniqueStorage()._iosExposureDetectionParameters = nil}

  var androidExposureDetectionParameters: SAP_Internal_ExposureDetectionParametersAndroid {
    get {return _storage._androidExposureDetectionParameters ?? SAP_Internal_ExposureDetectionParametersAndroid()}
    set {_uniqueStorage()._androidExposureDetectionParameters = newValue}
  }
  /// Returns true if `androidExposureDetectionParameters` has been explicitly set.
  var hasAndroidExposureDetectionParameters: Bool {return _storage._androidExposureDetectionParameters != nil}
  /// Clears the value of `androidExposureDetectionParameters`. Subsequent reads from it will return its default value.
  mutating func clearAndroidExposureDetectionParameters() {_uniqueStorage()._androidExposureDetectionParameters = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=5.5) && canImport(_Concurrency)
extension SAP_Internal_ApplicationConfiguration: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "SAP.internal"

extension SAP_Internal_ApplicationConfiguration: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ApplicationConfiguration"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "minRiskScore"),
    2: .same(proto: "riskScoreClasses"),
    3: .same(proto: "exposureConfig"),
    4: .same(proto: "attenuationDuration"),
    5: .same(proto: "appVersion"),
    6: .same(proto: "appFeatures"),
    7: .same(proto: "supportedCountries"),
    8: .same(proto: "iosKeyDownloadParameters"),
    9: .same(proto: "androidKeyDownloadParameters"),
    10: .same(proto: "iosExposureDetectionParameters"),
    11: .same(proto: "androidExposureDetectionParameters"),
  ]

  fileprivate class _StorageClass {
    var _minRiskScore: Int32 = 0
    var _riskScoreClasses: SAP_Internal_RiskScoreClassification? = nil
    var _exposureConfig: SAP_Internal_RiskScoreParameters? = nil
    var _attenuationDuration: SAP_Internal_AttenuationDuration? = nil
    var _appVersion: SAP_Internal_ApplicationVersionConfiguration? = nil
    var _appFeatures: SAP_Internal_AppFeatures? = nil
    var _supportedCountries: [String] = []
    var _iosKeyDownloadParameters: SAP_Internal_KeyDownloadParametersIOS? = nil
    var _androidKeyDownloadParameters: SAP_Internal_KeyDownloadParametersAndroid? = nil
    var _iosExposureDetectionParameters: SAP_Internal_ExposureDetectionParametersIOS? = nil
    var _androidExposureDetectionParameters: SAP_Internal_ExposureDetectionParametersAndroid? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _minRiskScore = source._minRiskScore
      _riskScoreClasses = source._riskScoreClasses
      _exposureConfig = source._exposureConfig
      _attenuationDuration = source._attenuationDuration
      _appVersion = source._appVersion
      _appFeatures = source._appFeatures
      _supportedCountries = source._supportedCountries
      _iosKeyDownloadParameters = source._iosKeyDownloadParameters
      _androidKeyDownloadParameters = source._androidKeyDownloadParameters
      _iosExposureDetectionParameters = source._iosExposureDetectionParameters
      _androidExposureDetectionParameters = source._androidExposureDetectionParameters
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularInt32Field(value: &_storage._minRiskScore) }()
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._riskScoreClasses) }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._exposureConfig) }()
        case 4: try { try decoder.decodeSingularMessageField(value: &_storage._attenuationDuration) }()
        case 5: try { try decoder.decodeSingularMessageField(value: &_storage._appVersion) }()
        case 6: try { try decoder.decodeSingularMessageField(value: &_storage._appFeatures) }()
        case 7: try { try decoder.decodeRepeatedStringField(value: &_storage._supportedCountries) }()
        case 8: try { try decoder.decodeSingularMessageField(value: &_storage._iosKeyDownloadParameters) }()
        case 9: try { try decoder.decodeSingularMessageField(value: &_storage._androidKeyDownloadParameters) }()
        case 10: try { try decoder.decodeSingularMessageField(value: &_storage._iosExposureDetectionParameters) }()
        case 11: try { try decoder.decodeSingularMessageField(value: &_storage._androidExposureDetectionParameters) }()
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      if _storage._minRiskScore != 0 {
        try visitor.visitSingularInt32Field(value: _storage._minRiskScore, fieldNumber: 1)
      }
      try { if let v = _storage._riskScoreClasses {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      try { if let v = _storage._exposureConfig {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      } }()
      try { if let v = _storage._attenuationDuration {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      } }()
      try { if let v = _storage._appVersion {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
      } }()
      try { if let v = _storage._appFeatures {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      } }()
      if !_storage._supportedCountries.isEmpty {
        try visitor.visitRepeatedStringField(value: _storage._supportedCountries, fieldNumber: 7)
      }
      try { if let v = _storage._iosKeyDownloadParameters {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
      } }()
      try { if let v = _storage._androidKeyDownloadParameters {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
      } }()
      try { if let v = _storage._iosExposureDetectionParameters {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
      } }()
      try { if let v = _storage._androidExposureDetectionParameters {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 11)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SAP_Internal_ApplicationConfiguration, rhs: SAP_Internal_ApplicationConfiguration) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._minRiskScore != rhs_storage._minRiskScore {return false}
        if _storage._riskScoreClasses != rhs_storage._riskScoreClasses {return false}
        if _storage._exposureConfig != rhs_storage._exposureConfig {return false}
        if _storage._attenuationDuration != rhs_storage._attenuationDuration {return false}
        if _storage._appVersion != rhs_storage._appVersion {return false}
        if _storage._appFeatures != rhs_storage._appFeatures {return false}
        if _storage._supportedCountries != rhs_storage._supportedCountries {return false}
        if _storage._iosKeyDownloadParameters != rhs_storage._iosKeyDownloadParameters {return false}
        if _storage._androidKeyDownloadParameters != rhs_storage._androidKeyDownloadParameters {return false}
        if _storage._iosExposureDetectionParameters != rhs_storage._iosExposureDetectionParameters {return false}
        if _storage._androidExposureDetectionParameters != rhs_storage._androidExposureDetectionParameters {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
