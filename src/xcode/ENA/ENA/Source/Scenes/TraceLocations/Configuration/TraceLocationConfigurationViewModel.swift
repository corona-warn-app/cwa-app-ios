//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIColor
import OpenCombine

class TraceLocationConfigurationViewModel {

	// MARK: - Init

	init(
		mode: Mode,
		eventStore: EventStoring
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

		self.eventStore = eventStore

		setUpBindings()
		checkForCompleteness()
	}

	// MARK: - Internal

	enum Mode {
		case new(TraceLocationType)
		case duplicate(TraceLocation)
	}

	enum SavingError: Error {
		case cryptographicSeedCreationFailed
		case qrCodePayloadCreationFailed
		case sqlStoreError(SecureSQLStoreError)
	}

	@OpenCombine.Published private(set) var startDatePickerIsHidden: Bool = true
	@OpenCombine.Published private(set) var endDatePickerIsHidden: Bool = true

	@OpenCombine.Published private(set) var startDateValueTextColor: UIColor = .enaColor(for: .textPrimary1)
	@OpenCombine.Published private(set) var endDateValueTextColor: UIColor = .enaColor(for: .textPrimary1)

	@OpenCombine.Published private(set) var temporaryDefaultLengthPickerIsHidden: Bool = true
	@OpenCombine.Published private(set) var temporaryDefaultLengthSwitchIsOn: Bool = false

	@OpenCombine.Published private(set) var permanentDefaultLengthPickerIsHidden: Bool = true
	@OpenCombine.Published private(set) var permanentDefaultLengthValueTextColor: UIColor = .enaColor(for: .textPrimary1)

	@OpenCombine.Published private(set) var primaryButtonIsEnabled: Bool = false

	@OpenCombine.Published private(set) var description: String! = ""
	@OpenCombine.Published private(set) var address: String! = ""
	@OpenCombine.Published var startDate: Date?
	@OpenCombine.Published var endDate: Date?
	@OpenCombine.Published private(set) var defaultCheckInLengthInMinutes: Int?

	@OpenCombine.Published private(set) var formattedStartDate: String?
	@OpenCombine.Published private(set) var formattedEndDate: String?
	@OpenCombine.Published private(set) var formattedDefaultCheckInLength: String?

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

	func save() throws {
		guard let cryptographicSeed = cryptographicSeed() else {
			throw SavingError.cryptographicSeedCreationFailed
		}

		let version = 1
		let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)

		let cnPublicKey = Data() // still TBD according to tech spec

		let cwaLocationData = SAP_Internal_Pt_CWALocationData.with {
			$0.version = 1
			$0.type = SAP_Internal_Pt_TraceLocationType(rawValue: traceLocationType.rawValue) ?? .locationTypeUnspecified
			$0.defaultCheckInLengthInMinutes = defaultCheckInLengthInMinutes.map { UInt32($0) } ?? 0
		}

		let cwaLocationSerializedData = try cwaLocationData.serializedData()

		let qrCodePayload = SAP_Internal_Pt_QRCodePayload.with {
			$0.version = 1

			$0.locationData.version = UInt32(version)
			$0.locationData.description_p = trimmedDescription
			$0.locationData.address = trimmedAddress
			$0.locationData.startTimestamp = startDate.map { UInt64($0.timeIntervalSince1970) } ?? 0
			$0.locationData.endTimestamp = endDate.map { UInt64($0.timeIntervalSince1970) } ?? 0

			$0.vendorData = cwaLocationSerializedData

			$0.crowdNotifierData.version = 1
			$0.crowdNotifierData.publicKey = cnPublicKey
			$0.crowdNotifierData.cryptographicSeed = cryptographicSeed
		}

		guard let id = qrCodePayload.id else {
			throw SavingError.qrCodePayloadCreationFailed
		}

		let storeResult = eventStore.createTraceLocation(
			TraceLocation(
				id: id,
				version: version,
				type: traceLocationType,
				description: trimmedDescription,
				address: trimmedAddress,
				startDate: startDate,
				endDate: endDate,
				defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
				cryptographicSeed: cryptographicSeed,
				cnPublicKey: cnPublicKey
			)
		)

		if case .failure(let error) = storeResult {
			throw SavingError.sqlStoreError(error)
		}
	}

	// MARK: - Private

	private let eventStore: EventStoring
	private let traceLocationType: TraceLocationType
	private let defaultDefaultCheckInLengthInMinutes: Int = 15

	private var subscriptions = Set<AnyCancellable>()

	private lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short

		return dateFormatter
	}()

	private lazy var durationFormatter: DateComponentsFormatter = {
		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad

		return dateComponentsFormatter
	}()

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
				guard
					let timeInterval = TimeInterval(minutes: $0),
					let formattedDuration = self?.durationFormatter.string(from: timeInterval)
				else {
					return nil
				}

				return String(format: AppStrings.TraceLocations.Configuration.hoursUnit, formattedDuration)
			}
			.assign(to: &$formattedDefaultCheckInLength)

		$permanentDefaultLengthPickerIsHidden
			.map { $0 ? UIColor.enaColor(for: .textPrimary1) : UIColor.enaColor(for: .textTint) }
			.assign(to: &$permanentDefaultLengthValueTextColor)
	}

	private func cryptographicSeed() -> Data? {
		var bytes = [UInt8](repeating: 0, count: 16)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			Log.error("Error creating random bytes.", log: .api)
			return nil
		}

		return Data(bytes)
	}

}
