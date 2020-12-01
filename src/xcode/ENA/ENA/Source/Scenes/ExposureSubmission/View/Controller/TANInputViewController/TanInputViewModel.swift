//
// 🦠 Corona-Warn-App
//

import Foundation

final class TanInputViewModel {
	
	// MARK: - Init
	
	init(
		exposureSubmissionService: ExposureSubmissionService,
		presentInvalidTanAlert: @escaping (String) -> Void,
		testGotResultSubmitted: @escaping () -> Void
	) {
		self.exposureSubmissionService = exposureSubmissionService
		self.presentInvalidTanAlert = presentInvalidTanAlert
		self.testGotResultSubmitted = testGotResultSubmitted
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol ENATanInputDelegate

	// MARK: - Public
	
	// MARK: - Internal

	var togglePrimaryButton: () -> Void = {}

	@discardableResult
	func submitTan(_ tanInput: String) -> Bool {
		// isChecksumValid will perfome isValid internal
		guard isChecksumValid(tanInput) else {
			return false
		}

		togglePrimaryButton()
		exposureSubmissionService.getRegistrationToken(forKey: .teleTan(tanInput)) { [weak self] result in
			switch result {
			case let .failure(error):
				// If teleTAN is incorrect, show Alert Controller
				self?.presentInvalidTanAlert(error.localizedDescription)
				self?.togglePrimaryButton()

			case .success:
				self?.testGotResultSubmitted()
			}
		}
		return true
	}

	func isValid(_ tan: String) -> Bool {
		let count = tan.count
		let digitGroups = { groups.split(separator: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }) }()
		let numberOfDigits = { digitGroups.reduce(0) { $0 + $1 } }()
		return count == numberOfDigits
	}

	func isChecksumValid(_ tan: String) -> Bool {
		guard isValid(tan) else { return false }
		let start = tan.index(tan.startIndex, offsetBy: 0)
		let end = tan.index(tan.startIndex, offsetBy: tan.count - 2)
		let testString = String(tan[start...end])
		return tan.last == calculateChecksum(input: testString)
	}

	// MARK: - Private

	private let exposureSubmissionService: ExposureSubmissionService
	private let presentInvalidTanAlert: (String) -> Void
	private let testGotResultSubmitted: () -> Void

	private var groups: String = "3,3,4"
	private var digitGroups: [Int] { groups.split(separator: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }) }

	private func calculateChecksum(input: String) -> Character? {
		let hash = Hasher.sha256(input)
		switch hash.first?.uppercased() {
		case "0":
			return "G"
		case "1":
			return "H"
		case .some(let c):
			return Character(c)
		default: return nil
		}
	}

}
