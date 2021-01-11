//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OptionGroupViewModel {

	struct Choice {
		let iconImage: UIImage?
		let title: String
		let accessibilityIdentifier: String?

		init(iconImage: UIImage?, title: String, accessibilityIdentifier: String? = nil) {
			self.iconImage = iconImage
			self.title = title
			self.accessibilityIdentifier = accessibilityIdentifier
		}
	}

	enum Option {
		case option(title: String, accessibilityIdentifier: String? = nil)
		case multipleChoiceOption(title: String, choices: [Choice], accessibilityIdentifier: String? = nil)
		case datePickerOption(title: String, today: Date = Date(), accessibilityIdentifier: String? = nil)
	}

	enum Selection: Equatable {
		case option(index: Int)
		case multipleChoiceOption(index: Int, selectedChoices: Set<Int>)
		case datePickerOption(index: Int, selectedDate: Date)
	}

	// MARK: - Init

	init(options: [Option], initialSelection: Selection? = nil) {
		self.options = options
		self.selection = initialSelection
	}

	// MARK: - Internal

	@OpenCombine.Published private(set) var selection: Selection?

	var options: [Option]

	func optionTapped(index: Int) {
		guard case .option = options[index] else {
			fatalError("Option at index \(index) is not of type .option")
		}

		selection = .option(index: index)
	}

	func multipleChoiceOptionTapped(index: Int, choiceIndex: Int) {
		guard case .multipleChoiceOption = options[index] else {
			fatalError("Option at index \(index) is not of type .multipleChoiceOption")
		}

		var newSelectedChoices = Set<Int>()
		if case .multipleChoiceOption(index: index, selectedChoices: let previouslySelectedChoices) = selection {
			newSelectedChoices = previouslySelectedChoices

			if previouslySelectedChoices.contains(choiceIndex) {
				newSelectedChoices.remove(choiceIndex)
			} else {
				newSelectedChoices.insert(choiceIndex)
			}
		} else {
			newSelectedChoices = [choiceIndex]
		}

		selection = newSelectedChoices.isEmpty ? nil : .multipleChoiceOption(index: index, selectedChoices: newSelectedChoices)
	}

	func datePickerOptionTapped(index: Int, date: Date) {
		guard case .datePickerOption = options[index] else {
			fatalError("Option at index \(index) is not of type .datePickerOption")
		}
		selection = .datePickerOption(index: index, selectedDate: date)
	}

}
