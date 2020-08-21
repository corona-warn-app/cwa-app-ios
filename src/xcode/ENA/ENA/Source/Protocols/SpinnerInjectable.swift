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

/// Allows to add and remove a default iOS activity indicator spinner.
protocol SpinnerInjectable: AnyObject {
	var spinner: UIActivityIndicatorView? { get set }
	var view: UIView! { get }
	func startSpinner()
	func stopSpinner()
}

extension SpinnerInjectable {
	func startSpinner() {
		if spinner != nil {
			// Do not add anything if spinner already exists.
			return
		}

		let spinner = UIActivityIndicatorView(style: .large)
		spinner.startAnimating()
		spinner.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(spinner)
		spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		spinner.center = view.center
		self.spinner = spinner
	}

	func stopSpinner() {
		if spinner == nil { return }
		spinner?.removeFromSuperview()
		spinner = nil
	}
}
