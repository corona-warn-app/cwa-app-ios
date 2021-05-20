//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class TanInputViewModel {
	
	// MARK: - Init
	
	init(
		coronaTestService: CoronaTestService,
		onSuccess: @escaping (CoronaTestRegistrationInformation, @escaping (Bool) -> Void) -> Void,
		givenTan: String? = nil
	) {
		self.coronaTestService = coronaTestService
		self.onSuccess = onSuccess
		self.text = givenTan ?? ""
	}
	
	// MARK: - Overrides

	// MARK: - Public

	@OpenCombine.Published private(set) var errorText: String = ""
	@OpenCombine.Published private(set) var isPrimaryButtonEnabled: Bool = false
	@OpenCombine.Published private(set) var isPrimaryBarButtonIsLoading: Bool = false

	private(set) var text: String = "" {
		didSet {
			isPrimaryButtonEnabled = isChecksumValid
		}
	}

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
			Log.debug("tried to submit tan \(private: text, public: "TeleTan ID"), but it is invalid")
			return
		}
		
		onSuccess(.teleTAN(text), { [weak self] isLoading in
			self?.isPrimaryButtonEnabled = !isLoading
			self?.isPrimaryBarButtonIsLoading = isLoading
		})
	}

	func addCharacter(_ char: String) {
		text += char
		updateErrorText()
	}

	func deleteLastCharacter() {
		text = String(text.dropLast())
		updateErrorText()
	}

	// MARK: - Private

	private func updateErrorText() {
		let errors = [
			isNumberOfDigitsReached && !isChecksumValid  ? AppStrings.ExposureSubmissionTanEntry.invalidError : nil,
			isInputBlocked ? AppStrings.ExposureSubmissionTanEntry.invalidCharacterError : nil
		].compactMap { $0 }
		errorText = errors.joined(separator: "\n\n")
	}

	private let coronaTestService: CoronaTestService
	private let onSuccess: (CoronaTestRegistrationInformation, @escaping (Bool) -> Void) -> Void

	private func calculateChecksum(input: String) -> Character? {
		let hash = ENAHasher.sha256(input)
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
