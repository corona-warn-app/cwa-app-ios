//
// 🦠 Corona-Warn-App
//

import UIKit

// Via: https://gist.github.com/ikh4everstudio/292582c8d11b3d2da175652051294e59
final class PagingCollectionViewLayout: UICollectionViewFlowLayout {

	var velocityThresholdPerPage: CGFloat = 2
	var numOfItemsPerPage: CGFloat = 1

	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView else { return proposedContentOffset }

		let pageLength: CGFloat
		let approxPage: CGFloat
		let currentPage: CGFloat
		let speed: CGFloat

		if scrollDirection == .horizontal {
			pageLength = (self.itemSize.width + self.minimumLineSpacing) * numOfItemsPerPage
			approxPage = collectionView.contentOffset.x / pageLength
			speed = velocity.x
		} else {
			pageLength = (self.itemSize.height + self.minimumLineSpacing) * numOfItemsPerPage
			approxPage = collectionView.contentOffset.y / pageLength
			speed = velocity.y
		}

		if speed < 0 {
			currentPage = ceil(approxPage)
		} else if speed > 0 {
			currentPage = floor(approxPage)
		} else {
			currentPage = round(approxPage)
		}

		guard speed != 0 else {
			if scrollDirection == .horizontal {
				return CGPoint(x: currentPage * pageLength, y: 0)
			} else {
				return CGPoint(x: 0, y: currentPage * pageLength)
			}
		}

		var nextPage: CGFloat = currentPage + (speed > 0 ? 1 : -1)

		let increment = speed / velocityThresholdPerPage
		nextPage += (speed < 0) ? ceil(increment) : floor(increment)

		if scrollDirection == .horizontal {
			return CGPoint(x: nextPage * pageLength, y: 0)
		} else {
			return CGPoint(x: 0, y: nextPage * pageLength)
		}
	}
}
