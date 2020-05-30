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

import Foundation
import UIKit

protocol NibLoadable: UIView {
	var nibView: UIView! { get }
	var nibName: String { get }
	var nib: UINib { get }

	func setupFromNib()
}

extension NibLoadable {
	var nibView: UIView! { subviews.first }

	var nibName: String { String(describing: type(of: self)) }

	var nib: UINib {
		let bundle = Bundle(for: type(of: self))
		return UINib(nibName: nibName, bundle: bundle)
	}

	func setupFromNib() {
		guard let view = nib.instantiate(
			withOwner: self,
			options: nil
		).first as? UIView else { return }
		addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		view.topAnchor.constraint(equalTo: topAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}
