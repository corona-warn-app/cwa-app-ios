//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

extension ENCalibrationConfidence: Codable { }
extension ENDiagnosisReportType: Codable { }
extension ENInfectiousness: Codable { }

struct ExposureWindow: Codable, Equatable {

	// MARK: - Init

	init(
		calibrationConfidence: ENCalibrationConfidence,
		date: Date,
		reportType: ENDiagnosisReportType,
		infectiousness: ENInfectiousness,
		scanInstances: [ScanInstance]
	) {
		self.calibrationConfidence = calibrationConfidence
		self.date = date
		self.reportType = reportType
		self.infectiousness = infectiousness
		self.scanInstances = scanInstances
	}

	init(from exposureWindow: ENExposureWindow) {
		self.calibrationConfidence = exposureWindow.calibrationConfidence
		self.date = exposureWindow.date
		self.reportType = exposureWindow.diagnosisReportType
		self.infectiousness = exposureWindow.infectiousness
		self.scanInstances = exposureWindow.scanInstances.map { ScanInstance(from: $0) }
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case calibrationConfidence, reportType, infectiousness, scanInstances
		case date = "ageInDays"
	}

	// MARK: - Protocol Equatable

	static func == (lhs: ExposureWindow, rhs: ExposureWindow) -> Bool {
		return  lhs.calibrationConfidence == rhs.calibrationConfidence &&
			lhs.date == rhs.date &&
			lhs.reportType == rhs.reportType &&
			lhs.infectiousness == rhs.infectiousness &&
			lhs.scanInstances == rhs.scanInstances
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let calibrationConfidence = try container.decode(ENCalibrationConfidence.self, forKey: .calibrationConfidence)
		let reportType = try container.decode(ENDiagnosisReportType.self, forKey: .reportType)
		let infectiousness = try container.decode(ENInfectiousness.self, forKey: .infectiousness)
		let scanInstances = try container.decode([ScanInstance].self, forKey: .scanInstances)

		let ageInDays = try container.decode(Int.self, forKey: .date)
		guard let date = Calendar.utcCalendar.date(byAdding: .day, value: -ageInDays, to: Calendar.utcCalendar.startOfDay(for: Date())) else {
			fatalError("Date could not be generated")
		}

		self.init(calibrationConfidence: calibrationConfidence, date: date, reportType: reportType, infectiousness: infectiousness, scanInstances: scanInstances)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(calibrationConfidence, forKey: .calibrationConfidence)
		try container.encode(reportType, forKey: .reportType)
		try container.encode(infectiousness, forKey: .infectiousness)
		try container.encode(scanInstances, forKey: .scanInstances)
		try container.encode(Calendar.current.dateComponents([.day], from: date, to: Calendar.current.startOfDay(for: Date())).day, forKey: .date)
	}

	// MARK: - Internal

	let calibrationConfidence: ENCalibrationConfidence
	let date: Date
	let reportType: ENDiagnosisReportType
	let infectiousness: ENInfectiousness
	let scanInstances: [ScanInstance]

}
