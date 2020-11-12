//
// 🦠 Corona-Warn-App
//

import UIKit

struct InfoBoxViewModel {

	struct InstructionStep {
		let icon: UIImage?
		let text: String
	}
	
	struct Instruction {
		let title: String
		let steps: [InstructionStep]
	}
	
	let instructions: [Instruction]
	let titleText: String
	let descriptionText: String
	let settingsText: String
	let shareText: String
	let settingsAction: () -> Void
	let shareAction: () -> Void

}
