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

			if type.type == .temporary {
				startDate = Date()
				endDate = Date()
			}
		case .duplicate(let traceLocation):
			traceLocationType = traceLocation.type
			description = traceLocation.description
			address = traceLocation.address
			startDate = traceLocation.startDate
			endDate = traceLocation.endDate
			defaultCheckInLengthInMinutes = traceLocation.defaultCheckInLengthInMinutes
		}

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
	@OpenCombine.Published var permanentDefaultLengthPickerIsHidden: Bool = true

	@OpenCombine.Published var description: String! = ""
	@OpenCombine.Published var address: String! = ""
	@OpenCombine.Published var startDate: Date?
	@OpenCombine.Published var formattedStartDate: String?
	@OpenCombine.Published var endDate: Date?
	@OpenCombine.Published var formattedEndDate: String?

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
		temporaryDefaultLengthPickerIsHidden.toggle()
	}

	func permanentDefaultLengthHeaderTapped() {
		permanentDefaultLengthPickerIsHidden.toggle()
	}

	func collapseAllSections() {
		startDatePickerIsHidden = true
		endDatePickerIsHidden = true
		permanentDefaultLengthPickerIsHidden = true
	}

	func save(completion: @escaping (Bool) -> Void) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			completion(true)
		}
	}

	// MARK: - Private

	private let traceLocationType: TraceLocationType
	private var defaultCheckInLengthInMinutes: Int?

	private var subscriptions = Set<AnyCancellable>()

}
