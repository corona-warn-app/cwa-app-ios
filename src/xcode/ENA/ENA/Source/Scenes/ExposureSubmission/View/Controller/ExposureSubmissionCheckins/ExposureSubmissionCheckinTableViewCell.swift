////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionCheckinTableViewCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	func configure(with cellModel: ExposureSubmissionCheckinCellModel) {
		self.cellModel = cellModel
	}
	
	// MARK: - Private
	
	var cellModel: ExposureSubmissionCheckinCellModel!
}
