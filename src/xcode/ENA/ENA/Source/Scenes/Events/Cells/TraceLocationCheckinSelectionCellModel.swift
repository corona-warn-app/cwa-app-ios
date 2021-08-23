////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol TraceLocationCheckinSelectionCellModel {

	var description: String { get }
	var address: String { get }
	var dateInterval: String? { get }
	var selected: Bool { get }

	var cellIsSelected: CurrentValueSubject<Bool, Never> { get }
	var checkmarkImage: CurrentValueSubject<UIImage?, Never> { get }

}
