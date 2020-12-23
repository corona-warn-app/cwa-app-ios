//
// 🦠 Corona-Warn-App
//

import UIKit


//protocol HomeItemViewModelAny {
//	var viewAnyType: UIView.Type { get }
//
//	func configureAny(riskView: UIView)
//}
//
//protocol HomeItemViewModel: HomeItemViewModelAny {
//	associatedtype ViewType: UIView
//	func configure(riskView: ViewType)
//}
//
//extension HomeItemViewModel {
//	var viewAnyType: UIView.Type {
//		ViewType.self
//	}
//
//	func configureAny(riskView: UIView) {
//		if let riskView = riskView as? ViewType {
//			configure(riskView: riskView)
//		} else {
//			let error = "\(riskView) isn't conformed ViewType"
//			Log.error(error, log: .ui)
//			fatalError(error)
//		}
//	}
//}



protocol HomeItemViewModel {

	var ViewType: HomeItemViewAny.Type { get }

}

protocol HomeItemViewAny: UIView {

	var viewModelAnyType: HomeItemViewModel.Type { get }

	func configureAny(with viewModel: HomeItemViewModel)

}

protocol HomeItemView: HomeItemViewAny {

	associatedtype ViewModelType: HomeItemViewModel

	func configure(with viewModel: ViewModelType)

}

extension HomeItemView {

	var viewModelAnyType: HomeItemViewModel.Type {
		ViewModelType.self
	}

	func configureAny(with viewModel: HomeItemViewModel) {
		if let viewModel = viewModel as? ViewModelType {
			configure(with: viewModel)
		} else {
			let error = "\(viewModel) isn't conformed ViewModelType"
			Log.error(error, log: .ui)
			fatalError(error)
		}
	}

}

protocol HomeItemViewSeparatorable {

	func hideSeparator()

}
