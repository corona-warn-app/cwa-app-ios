//
// 🦠 Corona-Warn-App
//

import Foundation
import Combine

final class TanInputViewModel {
	
	// MARK: - Init
	
	init(
		exposureSubmissionService: ExposureSubmissionService,
		presentInvalidTanAlert: @escaping (String, @escaping () -> Void) -> Void,
		tanSuccessfullyTransferred: @escaping () -> Void,
		givenTan: String = ""
	) {
		self.exposureSubmissionService = exposureSubmissionService
		self.presentInvalidTanAlert = presentInvalidTanAlert
		self.tanSuccessfullyTransferred = tanSuccessfullyTransferred
		self.text = givenTan
	}
	
	// MARK: - Overrides

	// MARK: - Public

	@Published private(set) var text: String = ""
	@Published private(set) var errorText: String = ""
	@Published private(set) var isPrimaryBarButtonDisabled: Bool = false

	// MARK: - Internal

	let digitGroups: [Int] = [3, 3, 4]

	var isInputBlocked: Bool = false
	var didDissMissInvalidTanAlert: (() -> Void)?

	var isNumberOfDigitsReached: Bool {
		let count = text.count
		let numberOfDigits = { digitGroups.reduce(0) { $0 + $1 } }()
		return count == numberOfDigits
	}

	var isChecksumValid: Bool {
		guard isNumberOfDigitsReached else { return false }
		let start = text.index(text.startIndex, offsetBy: 0)
		let end = text.index(text.startIndex, offsetBy: text.count - 2)
		let testString = String(text[start...end])
		return text.last == calculateChecksum(input: testString)
	}

	func submitTan() {
		// isChecksumValid will perfome isValid internal
		guard isChecksumValid else {
			Log.debug("tried to submit tan \(text), but ist'n invalid")
			return
		}

		isPrimaryBarButtonDisabled = true
		exposureSubmissionService.getRegistrationToken(forKey: .teleTan(text)) { [weak self] result in

			switch result {
			case let .failure(error):
				// If teleTAN is incorrect, show Alert Controller
				self?.isPrimaryBarButtonDisabled = false
				self?.presentInvalidTanAlert(error.localizedDescription) {
					self?.didDissMissInvalidTanAlert?()
				}

			case .success:
				self?.tanSuccessfullyTransferred()
			}
		}
	}

	func appendCharacter(_ char: String) {
		text += char
		updateErrorText()
	}

	func deletLastCharacter() {
		text = String(text.dropLast())
		updateErrorText()
	}

	func handleReturnKey() {
		submitTan()
	}

	// MARK: - Private

	private func updateErrorText() {
		let errors = [
			isNumberOfDigitsReached && !isChecksumValid  ? AppStrings.ExposureSubmissionTanEntry.invalidError : nil,
			isInputBlocked ? AppStrings.ExposureSubmissionTanEntry.invalidCharacterError : nil
		].compactMap { $0 }
		errorText = errors.joined(separator: "\n\n")
	}

	private let exposureSubmissionService: ExposureSubmissionService
	private let presentInvalidTanAlert: (String, @escaping () -> Void) -> Void
	private let tanSuccessfullyTransferred: () -> Void

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
