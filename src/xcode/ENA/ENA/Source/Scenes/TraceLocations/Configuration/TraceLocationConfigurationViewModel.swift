//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIColor
import OpenCombine

class TraceLocationConfigurationViewModel {

	// MARK: - Init

	init(
		mode: Mode
	) {
		switch mode {
		case .new(let type):
			traceLocationType = type

			switch type.type {
			case .temporary:
				startDate = Date()
				endDate = Date()
			case .permanent:
				defaultCheckInLengthInMinutes = defaultDefaultCheckInLengthInMinutes
			case .unspecified:
				break
			}
		case .duplicate(let traceLocation):
			traceLocationType = traceLocation.type
			description = traceLocation.description
			address = traceLocation.address
			startDate = traceLocation.startDate
			endDate = traceLocation.endDate
			defaultCheckInLengthInMinutes = traceLocation.defaultCheckInLengthInMinutes
		}

		setUpBindings()
	}

	// MARK: - Internal

	enum Mode {
		case new(TraceLocationType)
		case duplicate(TraceLocation)
	}

	@OpenCombine.Published var startDatePickerIsHidden: Bool = true
	@OpenCombine.Published var endDatePickerIsHidden: Bool = true

	@OpenCombine.Published var startDateValueTextColor: UIColor = .enaColor(for: .textPrimary1)
	@OpenCombine.Published var endDateValueTextColor: UIColor = .enaColor(for: .textPrimary1)

	@OpenCombine.Published var temporaryDefaultLengthPickerIsHidden: Bool = true
	@OpenCombine.Published var temporaryDefaultLengthSwitchIsOn: Bool = false

	@OpenCombine.Published var permanentDefaultLengthPickerIsHidden: Bool = true
	@OpenCombine.Published var permanentDefaultLengthValueTextColor: UIColor = .enaColor(for: .textPrimary1)

	@OpenCombine.Published var primaryButtonIsEnabled: Bool = false

	@OpenCombine.Published var description: String! = ""
	@OpenCombine.Published var address: String! = ""
	@OpenCombine.Published var startDate: Date?
	@OpenCombine.Published var formattedStartDate: String?
	@OpenCombine.Published var endDate: Date?
	@OpenCombine.Published var formattedEndDate: String?
	@OpenCombine.Published var defaultCheckInLengthInMinutes: Int?
	@OpenCombine.Published var formattedDefaultCheckInLength: String?

	var defaultDefaultCheckInLengthTimeInterval: TimeInterval {
		TimeInterval(defaultDefaultCheckInLengthInMinutes * 60)
	}

	var traceLocationTypeTitle: String {
		traceLocationType.title
	}

	var temporarySettingsContainerIsHidden: Bool {
		traceLocationType.type != .temporary
	}

	var permanentSettingsContainerIsHidden: Bool {
		traceLocationType.type != .permanent
	}

	lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short

		return dateFormatter
	}()

	lazy var durationFormatter: DateComponentsFormatter = {
		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad

		return dateComponentsFormatter
	}()

	func startDateHeaderTapped() {
		startDatePickerIsHidden.toggle()

		if !startDatePickerIsHidden {
			endDatePickerIsHidden = true
		}
	}

	func endDateHeaderTapped() {
		endDatePickerIsHidden.toggle()

		if !endDatePickerIsHidden {
			startDatePickerIsHidden = true
		}
	}

	func temporaryDefaultLengthHeaderTapped() {
		if defaultCheckInLengthInMinutes == nil {
			defaultCheckInLengthInMinutes = defaultDefaultCheckInLengthInMinutes
		} else {
			defaultCheckInLengthInMinutes = nil
		}
	}

	func temporaryDefaultLengthSwitchSet(to isOn: Bool) {
		if defaultCheckInLengthInMinutes == nil && isOn {
			defaultCheckInLengthInMinutes = defaultDefaultCheckInLengthInMinutes
		} else if !isOn {
			defaultCheckInLengthInMinutes = nil
		}
	}

	func permanentDefaultLengthHeaderTapped() {
		permanentDefaultLengthPickerIsHidden.toggle()
	}

	func defaultCheckinLengthValueChanged(to timeInterval: TimeInterval) {
		defaultCheckInLengthInMinutes = Int(timeInterval / 60)
	}

	func collapseAllSections() {
		startDatePickerIsHidden = true
		endDatePickerIsHidden = true
		permanentDefaultLengthPickerIsHidden = true
	}

	func update(description: String) {
		self.description = description
		checkForCompleteness()
	}

	func update(address: String) {
		self.address = address
		checkForCompleteness()
	}

	func checkForCompleteness() {
		let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)

		primaryButtonIsEnabled = !trimmedDescription.isEmpty && !trimmedAddress.isEmpty
	}

	func save(completion: @escaping (Bool) -> Void) {
		var traceLocation = SAP_Internal_Pt_TraceLocation()
		traceLocation.version = 1
		traceLocation.description_p = description.trimmingCharacters(in: .whitespacesAndNewlines)
		traceLocation.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
		traceLocation.startTimestamp = startDate?.unsignedTimeIntervalSince1970 ?? 0
		traceLocation.endTimestamp = endDate?.unsignedTimeIntervalSince1970 ?? 0
		traceLocation.defaultCheckInLengthInMinutes = defaultCheckInLengthInMinutes.map { UInt32($0) } ?? 0

		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			completion(true)
		}
	}

	// MARK: - Private

	private let traceLocationType: TraceLocationType

	private let defaultDefaultCheckInLengthInMinutes: Int = 15

	private var subscriptions = Set<AnyCancellable>()

	private func setUpBindings() {
		$startDate
			.compactMap { [weak self] in
				$0.map { self?.dateFormatter.string(from: $0) }
			}
			.assign(to: &$formattedStartDate)

		$startDate
			.sink { [weak self] startDate in
				guard let self = self, let startDate = startDate, let endDate = self.endDate else {
					return
				}

				if endDate < startDate {
					self.endDate = startDate
				}
			}
			.store(in: &subscriptions)

		$endDate
			.compactMap { [weak self] in
				$0.map { self?.dateFormatter.string(from: $0) }
			}
			.assign(to: &$formattedEndDate)

		$startDatePickerIsHidden
			.map { $0 ? UIColor.enaColor(for: .textPrimary1) : UIColor.enaColor(for: .textTint) }
			.assign(to: &$startDateValueTextColor)

		$endDatePickerIsHidden
			.map { $0 ? UIColor.enaColor(for: .textPrimary1) : UIColor.enaColor(for: .textTint) }
			.assign(to: &$endDateValueTextColor)

		$defaultCheckInLengthInMinutes
			.map { $0 == nil }
			.assign(to: &$temporaryDefaultLengthPickerIsHidden)

		$defaultCheckInLengthInMinutes
			.map { $0 != nil }
			.assign(to: &$temporaryDefaultLengthSwitchIsOn)

		$defaultCheckInLengthInMinutes
			.compactMap { [weak self] in
				TimeInterval(minutes: $0).map { self?.durationFormatter.string(from: $0) }
			}
			.assign(to: &$formattedDefaultCheckInLength)

		$permanentDefaultLengthPickerIsHidden
			.map { $0 ? UIColor.enaColor(for: .textPrimary1) : UIColor.enaColor(for: .textTint) }
			.assign(to: &$permanentDefaultLengthValueTextColor)
	}

}

extension Date {

	var unsignedTimeIntervalSince1970: UInt64 {
		UInt64(timeIntervalSince1970)
	}

}
