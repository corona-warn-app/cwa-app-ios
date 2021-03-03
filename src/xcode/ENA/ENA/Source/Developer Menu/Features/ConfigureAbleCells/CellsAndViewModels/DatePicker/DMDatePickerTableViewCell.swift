////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMDatePickerTableViewCell: UITableViewCell, DMConfigureableCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

	}

	// MARK: - Internal

	func configure<T>(cellViewModel: T) {

	}

	// MARK: - Private

	private var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker(frame: .zero)
		return datePicker
	}()

}

#endif
