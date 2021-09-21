//
// 🦠 Corona-Warn-App
//

import UIKit


final class CovPassCheckInformationViewModel {
	
	// MARK: - Init
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(headerText: "Hallo Welt", image: UIImage(imageLiteralResourceName: "Illu_CovPass_Check"))
				]
			)
		])
	}
	
	// MARK: - Private
}
