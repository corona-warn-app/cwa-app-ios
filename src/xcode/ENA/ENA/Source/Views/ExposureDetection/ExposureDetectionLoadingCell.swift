import Foundation
import UIKit

class ExposureDetectionLoadingCell: UITableViewCell {
	@IBOutlet var activityIndicatorView: UIActivityIndicatorView!

	override func prepareForReuse() {
		super.prepareForReuse()
		activityIndicatorView.startAnimating()
	}
}
