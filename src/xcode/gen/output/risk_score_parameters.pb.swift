// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: risk_score_parameters.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

/// See page 15:
/// https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ExposureNotification-FrameworkDocumentationv1.2.pdf

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
	struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
	typealias Version = _2
}

struct SAP_RiskScoreParameters {
	// SwiftProtobuf.Message conformance is added in an extension below. See the
	// `Message` and `Message+*Additions` files in the SwiftProtobuf library for
	// methods supported on all messages.

	/// App-specific mapping
	var transmission: SAP_RiskScoreParameters.TransmissionRiskParameters {
		get { _transmission ?? SAP_RiskScoreParameters.TransmissionRiskParameters() }
		set { _transmission = newValue }
	}

	/// Returns true if `transmission` has been explicitly set.
	var hasTransmission: Bool { self._transmission != nil }
	/// Clears the value of `transmission`. Subsequent reads from it will return its default value.
	mutating func clearTransmission() { _transmission = nil }

	var transmissionWeight: Double = 0

	var duration: SAP_RiskScoreParameters.DurationRiskParameters {
		get { _duration ?? SAP_RiskScoreParameters.DurationRiskParameters() }
		set { _duration = newValue }
	}

	/// Returns true if `duration` has been explicitly set.
	var hasDuration: Bool { self._duration != nil }
	/// Clears the value of `duration`. Subsequent reads from it will return its default value.
	mutating func clearDuration() { _duration = nil }

	var durationWeight: Double = 0

	var daysSinceLastExposure: SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters {
		get { _daysSinceLastExposure ?? SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters() }
		set { _daysSinceLastExposure = newValue }
	}

	/// Returns true if `daysSinceLastExposure` has been explicitly set.
	var hasDaysSinceLastExposure: Bool { self._daysSinceLastExposure != nil }
	/// Clears the value of `daysSinceLastExposure`. Subsequent reads from it will return its default value.
	mutating func clearDaysSinceLastExposure() { _daysSinceLastExposure = nil }

	var daysWeight: Double = 0

	var attenuation: SAP_RiskScoreParameters.AttenuationRiskParameters {
		get { _attenuation ?? SAP_RiskScoreParameters.AttenuationRiskParameters() }
		set { _attenuation = newValue }
	}

	/// Returns true if `attenuation` has been explicitly set.
	var hasAttenuation: Bool { self._attenuation != nil }
	/// Clears the value of `attenuation`. Subsequent reads from it will return its default value.
	mutating func clearAttenuation() { _attenuation = nil }

	var attenuationWeight: Double = 0

	var unknownFields = SwiftProtobuf.UnknownStorage()

	struct TransmissionRiskParameters {
		// SwiftProtobuf.Message conformance is added in an extension below. See the
		// `Message` and `Message+*Additions` files in the SwiftProtobuf library for
		// methods supported on all messages.

		var appDefined1: SAP_RiskLevel = .unspecified

		var appDefined2: SAP_RiskLevel = .unspecified

		var appDefined3: SAP_RiskLevel = .unspecified

		var appDefined4: SAP_RiskLevel = .unspecified

		var appDefined5: SAP_RiskLevel = .unspecified

		var appDefined6: SAP_RiskLevel = .unspecified

		var appDefined7: SAP_RiskLevel = .unspecified

		var appDefined8: SAP_RiskLevel = .unspecified

		var unknownFields = SwiftProtobuf.UnknownStorage()

		init() {}
	}

	struct DurationRiskParameters {
		// SwiftProtobuf.Message conformance is added in an extension below. See the
		// `Message` and `Message+*Additions` files in the SwiftProtobuf library for
		// methods supported on all messages.

		/// D = 0 min, lowest risk
		var eq0Min: SAP_RiskLevel = .unspecified

		/// 0 < D <= 5 min
		var gt0Le5Min: SAP_RiskLevel = .unspecified

		/// 5 < D <= 10 min
		var gt5Le10Min: SAP_RiskLevel = .unspecified

		/// 10 < D <= 15 min
		var gt10Le15Min: SAP_RiskLevel = .unspecified

		/// 15 < D <= 20 min
		var gt15Le20Min: SAP_RiskLevel = .unspecified

		/// 20 < D <= 25 min
		var gt20Le25Min: SAP_RiskLevel = .unspecified

		/// 25 < D <= 30 min
		var gt25Le30Min: SAP_RiskLevel = .unspecified

		/// > 30 min, highest risk
		var gt30Min: SAP_RiskLevel = .unspecified

		var unknownFields = SwiftProtobuf.UnknownStorage()

		init() {}
	}

	struct DaysSinceLastExposureRiskParameters {
		// SwiftProtobuf.Message conformance is added in an extension below. See the
		// `Message` and `Message+*Additions` files in the SwiftProtobuf library for
		// methods supported on all messages.

		/// D >= 14 days, lowest risk
		var ge14Days: SAP_RiskLevel = .unspecified

		/// 12 <= D < 14 days
		var ge12Lt14Days: SAP_RiskLevel = .unspecified

		/// 10 <= D < 12 days
		var ge10Lt12Days: SAP_RiskLevel = .unspecified

		/// 8 <= D < 10 days
		var ge8Lt10Days: SAP_RiskLevel = .unspecified

		/// 6 <= D < 8 days
		var ge6Lt8Days: SAP_RiskLevel = .unspecified

		/// 4 <= D < 6 days
		var ge4Lt6Days: SAP_RiskLevel = .unspecified

		/// 2 <= D < 4 days
		var ge2Lt4Days: SAP_RiskLevel = .unspecified

		/// 0 <= D < 2 days, highest risk
		var ge0Lt2Days: SAP_RiskLevel = .unspecified

		var unknownFields = SwiftProtobuf.UnknownStorage()

		init() {}
	}

	struct AttenuationRiskParameters {
		// SwiftProtobuf.Message conformance is added in an extension below. See the
		// `Message` and `Message+*Additions` files in the SwiftProtobuf library for
		// methods supported on all messages.

		/// A > 73 dBm, lowest risk
		var gt73Dbm: SAP_RiskLevel = .unspecified

		/// 63 < A <= 73 dBm
		var gt63Le73Dbm: SAP_RiskLevel = .unspecified

		/// 51 < A <= 63 dBm
		var gt51Le63Dbm: SAP_RiskLevel = .unspecified

		/// 33 < A <= 51 dBm
		var gt33Le51Dbm: SAP_RiskLevel = .unspecified

		/// 27 < A <= 33 dBm
		var gt27Le33Dbm: SAP_RiskLevel = .unspecified

		/// 15 < A <= 27 dBm
		var gt15Le27Dbm: SAP_RiskLevel = .unspecified

		/// 10 < A <= 15 dBm
		var gt10Le15Dbm: SAP_RiskLevel = .unspecified

		/// A <= 10 dBm, highest risk
		var lt10Dbm: SAP_RiskLevel = .unspecified

		var unknownFields = SwiftProtobuf.UnknownStorage()

		init() {}
	}

	init() {}

	fileprivate var _transmission: SAP_RiskScoreParameters.TransmissionRiskParameters?
	fileprivate var _duration: SAP_RiskScoreParameters.DurationRiskParameters?
	fileprivate var _daysSinceLastExposure: SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters?
	fileprivate var _attenuation: SAP_RiskScoreParameters.AttenuationRiskParameters?
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "SAP"

extension SAP_RiskScoreParameters: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
	static let protoMessageName: String = _protobuf_package + ".RiskScoreParameters"
	static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
		1: .same(proto: "transmission"),
		2: .standard(proto: "transmission_weight"),
		3: .same(proto: "duration"),
		4: .standard(proto: "duration_weight"),
		5: .standard(proto: "days_since_last_exposure"),
		6: .standard(proto: "days_weight"),
		7: .same(proto: "attenuation"),
		8: .standard(proto: "attenuation_weight"),
	]

	mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
		while let fieldNumber = try decoder.nextFieldNumber() {
			switch fieldNumber {
			case 1: try decoder.decodeSingularMessageField(value: &_transmission)
			case 2: try decoder.decodeSingularDoubleField(value: &transmissionWeight)
			case 3: try decoder.decodeSingularMessageField(value: &_duration)
			case 4: try decoder.decodeSingularDoubleField(value: &durationWeight)
			case 5: try decoder.decodeSingularMessageField(value: &_daysSinceLastExposure)
			case 6: try decoder.decodeSingularDoubleField(value: &daysWeight)
			case 7: try decoder.decodeSingularMessageField(value: &_attenuation)
			case 8: try decoder.decodeSingularDoubleField(value: &attenuationWeight)
			default: break
			}
		}
	}

	func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
		if let v = _transmission {
			try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
		}
		if transmissionWeight != 0 {
			try visitor.visitSingularDoubleField(value: transmissionWeight, fieldNumber: 2)
		}
		if let v = _duration {
			try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
		}
		if durationWeight != 0 {
			try visitor.visitSingularDoubleField(value: durationWeight, fieldNumber: 4)
		}
		if let v = _daysSinceLastExposure {
			try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
		}
		if daysWeight != 0 {
			try visitor.visitSingularDoubleField(value: daysWeight, fieldNumber: 6)
		}
		if let v = _attenuation {
			try visitor.visitSingularMessageField(value: v, fieldNumber: 7)
		}
		if attenuationWeight != 0 {
			try visitor.visitSingularDoubleField(value: attenuationWeight, fieldNumber: 8)
		}
		try unknownFields.traverse(visitor: &visitor)
	}

	static func == (lhs: SAP_RiskScoreParameters, rhs: SAP_RiskScoreParameters) -> Bool {
		if lhs._transmission != rhs._transmission { return false }
		if lhs.transmissionWeight != rhs.transmissionWeight { return false }
		if lhs._duration != rhs._duration { return false }
		if lhs.durationWeight != rhs.durationWeight { return false }
		if lhs._daysSinceLastExposure != rhs._daysSinceLastExposure { return false }
		if lhs.daysWeight != rhs.daysWeight { return false }
		if lhs._attenuation != rhs._attenuation { return false }
		if lhs.attenuationWeight != rhs.attenuationWeight { return false }
		if lhs.unknownFields != rhs.unknownFields { return false }
		return true
	}
}

extension SAP_RiskScoreParameters.TransmissionRiskParameters: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
	static let protoMessageName: String = SAP_RiskScoreParameters.protoMessageName + ".TransmissionRiskParameters"
	static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
		1: .standard(proto: "app_defined_1"),
		2: .standard(proto: "app_defined_2"),
		3: .standard(proto: "app_defined_3"),
		4: .standard(proto: "app_defined_4"),
		5: .standard(proto: "app_defined_5"),
		6: .standard(proto: "app_defined_6"),
		7: .standard(proto: "app_defined_7"),
		8: .standard(proto: "app_defined_8"),
	]

	mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
		while let fieldNumber = try decoder.nextFieldNumber() {
			switch fieldNumber {
			case 1: try decoder.decodeSingularEnumField(value: &appDefined1)
			case 2: try decoder.decodeSingularEnumField(value: &appDefined2)
			case 3: try decoder.decodeSingularEnumField(value: &appDefined3)
			case 4: try decoder.decodeSingularEnumField(value: &appDefined4)
			case 5: try decoder.decodeSingularEnumField(value: &appDefined5)
			case 6: try decoder.decodeSingularEnumField(value: &appDefined6)
			case 7: try decoder.decodeSingularEnumField(value: &appDefined7)
			case 8: try decoder.decodeSingularEnumField(value: &appDefined8)
			default: break
			}
		}
	}

	func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
		if appDefined1 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined1, fieldNumber: 1)
		}
		if appDefined2 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined2, fieldNumber: 2)
		}
		if appDefined3 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined3, fieldNumber: 3)
		}
		if appDefined4 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined4, fieldNumber: 4)
		}
		if appDefined5 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined5, fieldNumber: 5)
		}
		if appDefined6 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined6, fieldNumber: 6)
		}
		if appDefined7 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined7, fieldNumber: 7)
		}
		if appDefined8 != .unspecified {
			try visitor.visitSingularEnumField(value: appDefined8, fieldNumber: 8)
		}
		try unknownFields.traverse(visitor: &visitor)
	}

	static func == (lhs: SAP_RiskScoreParameters.TransmissionRiskParameters, rhs: SAP_RiskScoreParameters.TransmissionRiskParameters) -> Bool {
		if lhs.appDefined1 != rhs.appDefined1 { return false }
		if lhs.appDefined2 != rhs.appDefined2 { return false }
		if lhs.appDefined3 != rhs.appDefined3 { return false }
		if lhs.appDefined4 != rhs.appDefined4 { return false }
		if lhs.appDefined5 != rhs.appDefined5 { return false }
		if lhs.appDefined6 != rhs.appDefined6 { return false }
		if lhs.appDefined7 != rhs.appDefined7 { return false }
		if lhs.appDefined8 != rhs.appDefined8 { return false }
		if lhs.unknownFields != rhs.unknownFields { return false }
		return true
	}
}

extension SAP_RiskScoreParameters.DurationRiskParameters: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
	static let protoMessageName: String = SAP_RiskScoreParameters.protoMessageName + ".DurationRiskParameters"
	static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
		1: .standard(proto: "eq_0_min"),
		2: .standard(proto: "gt_0_le_5_min"),
		3: .standard(proto: "gt_5_le_10_min"),
		4: .standard(proto: "gt_10_le_15_min"),
		5: .standard(proto: "gt_15_le_20_min"),
		6: .standard(proto: "gt_20_le_25_min"),
		7: .standard(proto: "gt_25_le_30_min"),
		8: .standard(proto: "gt_30_min"),
	]

	mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
		while let fieldNumber = try decoder.nextFieldNumber() {
			switch fieldNumber {
			case 1: try decoder.decodeSingularEnumField(value: &eq0Min)
			case 2: try decoder.decodeSingularEnumField(value: &gt0Le5Min)
			case 3: try decoder.decodeSingularEnumField(value: &gt5Le10Min)
			case 4: try decoder.decodeSingularEnumField(value: &gt10Le15Min)
			case 5: try decoder.decodeSingularEnumField(value: &gt15Le20Min)
			case 6: try decoder.decodeSingularEnumField(value: &gt20Le25Min)
			case 7: try decoder.decodeSingularEnumField(value: &gt25Le30Min)
			case 8: try decoder.decodeSingularEnumField(value: &gt30Min)
			default: break
			}
		}
	}

	func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
		if eq0Min != .unspecified {
			try visitor.visitSingularEnumField(value: eq0Min, fieldNumber: 1)
		}
		if gt0Le5Min != .unspecified {
			try visitor.visitSingularEnumField(value: gt0Le5Min, fieldNumber: 2)
		}
		if gt5Le10Min != .unspecified {
			try visitor.visitSingularEnumField(value: gt5Le10Min, fieldNumber: 3)
		}
		if gt10Le15Min != .unspecified {
			try visitor.visitSingularEnumField(value: gt10Le15Min, fieldNumber: 4)
		}
		if gt15Le20Min != .unspecified {
			try visitor.visitSingularEnumField(value: gt15Le20Min, fieldNumber: 5)
		}
		if gt20Le25Min != .unspecified {
			try visitor.visitSingularEnumField(value: gt20Le25Min, fieldNumber: 6)
		}
		if gt25Le30Min != .unspecified {
			try visitor.visitSingularEnumField(value: gt25Le30Min, fieldNumber: 7)
		}
		if gt30Min != .unspecified {
			try visitor.visitSingularEnumField(value: gt30Min, fieldNumber: 8)
		}
		try unknownFields.traverse(visitor: &visitor)
	}

	static func == (lhs: SAP_RiskScoreParameters.DurationRiskParameters, rhs: SAP_RiskScoreParameters.DurationRiskParameters) -> Bool {
		if lhs.eq0Min != rhs.eq0Min { return false }
		if lhs.gt0Le5Min != rhs.gt0Le5Min { return false }
		if lhs.gt5Le10Min != rhs.gt5Le10Min { return false }
		if lhs.gt10Le15Min != rhs.gt10Le15Min { return false }
		if lhs.gt15Le20Min != rhs.gt15Le20Min { return false }
		if lhs.gt20Le25Min != rhs.gt20Le25Min { return false }
		if lhs.gt25Le30Min != rhs.gt25Le30Min { return false }
		if lhs.gt30Min != rhs.gt30Min { return false }
		if lhs.unknownFields != rhs.unknownFields { return false }
		return true
	}
}

extension SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
	static let protoMessageName: String = SAP_RiskScoreParameters.protoMessageName + ".DaysSinceLastExposureRiskParameters"
	static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
		1: .standard(proto: "ge_14_days"),
		2: .standard(proto: "ge_12_lt_14_days"),
		3: .standard(proto: "ge_10_lt_12_days"),
		4: .standard(proto: "ge_8_lt_10_days"),
		5: .standard(proto: "ge_6_lt_8_days"),
		6: .standard(proto: "ge_4_lt_6_days"),
		7: .standard(proto: "ge_2_lt_4_days"),
		8: .standard(proto: "ge_0_lt_2_days"),
	]

	mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
		while let fieldNumber = try decoder.nextFieldNumber() {
			switch fieldNumber {
			case 1: try decoder.decodeSingularEnumField(value: &ge14Days)
			case 2: try decoder.decodeSingularEnumField(value: &ge12Lt14Days)
			case 3: try decoder.decodeSingularEnumField(value: &ge10Lt12Days)
			case 4: try decoder.decodeSingularEnumField(value: &ge8Lt10Days)
			case 5: try decoder.decodeSingularEnumField(value: &ge6Lt8Days)
			case 6: try decoder.decodeSingularEnumField(value: &ge4Lt6Days)
			case 7: try decoder.decodeSingularEnumField(value: &ge2Lt4Days)
			case 8: try decoder.decodeSingularEnumField(value: &ge0Lt2Days)
			default: break
			}
		}
	}

	func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
		if ge14Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge14Days, fieldNumber: 1)
		}
		if ge12Lt14Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge12Lt14Days, fieldNumber: 2)
		}
		if ge10Lt12Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge10Lt12Days, fieldNumber: 3)
		}
		if ge8Lt10Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge8Lt10Days, fieldNumber: 4)
		}
		if ge6Lt8Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge6Lt8Days, fieldNumber: 5)
		}
		if ge4Lt6Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge4Lt6Days, fieldNumber: 6)
		}
		if ge2Lt4Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge2Lt4Days, fieldNumber: 7)
		}
		if ge0Lt2Days != .unspecified {
			try visitor.visitSingularEnumField(value: ge0Lt2Days, fieldNumber: 8)
		}
		try unknownFields.traverse(visitor: &visitor)
	}

	static func == (lhs: SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters, rhs: SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters) -> Bool {
		if lhs.ge14Days != rhs.ge14Days { return false }
		if lhs.ge12Lt14Days != rhs.ge12Lt14Days { return false }
		if lhs.ge10Lt12Days != rhs.ge10Lt12Days { return false }
		if lhs.ge8Lt10Days != rhs.ge8Lt10Days { return false }
		if lhs.ge6Lt8Days != rhs.ge6Lt8Days { return false }
		if lhs.ge4Lt6Days != rhs.ge4Lt6Days { return false }
		if lhs.ge2Lt4Days != rhs.ge2Lt4Days { return false }
		if lhs.ge0Lt2Days != rhs.ge0Lt2Days { return false }
		if lhs.unknownFields != rhs.unknownFields { return false }
		return true
	}
}

extension SAP_RiskScoreParameters.AttenuationRiskParameters: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
	static let protoMessageName: String = SAP_RiskScoreParameters.protoMessageName + ".AttenuationRiskParameters"
	static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
		1: .standard(proto: "gt_73_dbm"),
		2: .standard(proto: "gt_63_le_73_dbm"),
		3: .standard(proto: "gt_51_le_63_dbm"),
		4: .standard(proto: "gt_33_le_51_dbm"),
		5: .standard(proto: "gt_27_le_33_dbm"),
		6: .standard(proto: "gt_15_le_27_dbm"),
		7: .standard(proto: "gt_10_le_15_dbm"),
		8: .standard(proto: "lt_10_dbm"),
	]

	mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
		while let fieldNumber = try decoder.nextFieldNumber() {
			switch fieldNumber {
			case 1: try decoder.decodeSingularEnumField(value: &gt73Dbm)
			case 2: try decoder.decodeSingularEnumField(value: &gt63Le73Dbm)
			case 3: try decoder.decodeSingularEnumField(value: &gt51Le63Dbm)
			case 4: try decoder.decodeSingularEnumField(value: &gt33Le51Dbm)
			case 5: try decoder.decodeSingularEnumField(value: &gt27Le33Dbm)
			case 6: try decoder.decodeSingularEnumField(value: &gt15Le27Dbm)
			case 7: try decoder.decodeSingularEnumField(value: &gt10Le15Dbm)
			case 8: try decoder.decodeSingularEnumField(value: &lt10Dbm)
			default: break
			}
		}
	}

	func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
		if gt73Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: gt73Dbm, fieldNumber: 1)
		}
		if gt63Le73Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: gt63Le73Dbm, fieldNumber: 2)
		}
		if gt51Le63Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: gt51Le63Dbm, fieldNumber: 3)
		}
		if gt33Le51Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: gt33Le51Dbm, fieldNumber: 4)
		}
		if gt27Le33Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: gt27Le33Dbm, fieldNumber: 5)
		}
		if gt15Le27Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: gt15Le27Dbm, fieldNumber: 6)
		}
		if gt10Le15Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: gt10Le15Dbm, fieldNumber: 7)
		}
		if lt10Dbm != .unspecified {
			try visitor.visitSingularEnumField(value: lt10Dbm, fieldNumber: 8)
		}
		try unknownFields.traverse(visitor: &visitor)
	}

	static func == (lhs: SAP_RiskScoreParameters.AttenuationRiskParameters, rhs: SAP_RiskScoreParameters.AttenuationRiskParameters) -> Bool {
		if lhs.gt73Dbm != rhs.gt73Dbm { return false }
		if lhs.gt63Le73Dbm != rhs.gt63Le73Dbm { return false }
		if lhs.gt51Le63Dbm != rhs.gt51Le63Dbm { return false }
		if lhs.gt33Le51Dbm != rhs.gt33Le51Dbm { return false }
		if lhs.gt27Le33Dbm != rhs.gt27Le33Dbm { return false }
		if lhs.gt15Le27Dbm != rhs.gt15Le27Dbm { return false }
		if lhs.gt10Le15Dbm != rhs.gt10Le15Dbm { return false }
		if lhs.lt10Dbm != rhs.lt10Dbm { return false }
		if lhs.unknownFields != rhs.unknownFields { return false }
		return true
	}
}
