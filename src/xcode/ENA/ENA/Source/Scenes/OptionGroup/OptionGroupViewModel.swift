//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import UIKit
import Combine

class OptionGroupViewModel {

	struct Choice {
		let iconImage: UIImage?
		let title: String
	}

	enum Option {
		case option(title: String, accessibilityIdentifier: String? = nil)
		case multipleChoiceOption(title: String, choices: [Choice])
	}

	enum Selection: Equatable {
		case option(index: Int)
		case multipleChoiceOption(index: Int, selectedChoices: Set<Int>)
	}

	// MARK: - Init

	init(options: [Option], initialSelection: Selection? = nil) {
		self.options = options
		self.selection = initialSelection
	}

	// MARK: - Internal

	@Published private(set) var selection: Selection?

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

}
