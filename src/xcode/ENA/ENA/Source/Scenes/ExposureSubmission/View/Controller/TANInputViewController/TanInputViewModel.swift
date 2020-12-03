//
// 🦠 Corona-Warn-App
//

import Foundation
import Combine

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

	@Published private(set) var text: String = ""

	var togglePrimaryButton: () -> Void = {}
	var digitGroups: [Int] {
		groups.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
	}

	@discardableResult
	func submitTan() -> Bool {
		// isChecksumValid will perfome isValid internal
		guard isChecksumValid else {
			return false
		}

		togglePrimaryButton()
		exposureSubmissionService.getRegistrationToken(forKey: .teleTan(text)) { [weak self] result in
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


	func appendCharacter(_ char: String) {
		text += char
	}

	func deletLastCharacter() {
		text = String(text.dropLast())
	}

	func handleReturnKey() {
		submitTan()
	}

	var isValid: Bool {
		let count = text.count
		let digitGroups = { groups.split(separator: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }) }()
		let numberOfDigits = { digitGroups.reduce(0) { $0 + $1 } }()
		return count == numberOfDigits
	}

	var isChecksumValid: Bool {
		guard isValid else { return false }
		let start = text.index(text.startIndex, offsetBy: 0)
		let end = text.index(text.startIndex, offsetBy: text.count - 2)
		let testString = String(text[start...end])
		return text.last == calculateChecksum(input: testString)
	}

	// MARK: - Private

	private let exposureSubmissionService: ExposureSubmissionService
	private let presentInvalidTanAlert: (String) -> Void
	private let testGotResultSubmitted: () -> Void

	private var groups: String = "3,3,4"

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
