//
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
//

import Foundation
import UIKit

@IBDesignable
class ENAFooterView: UIVisualEffectView {
	@IBInspectable var isTranslucent: Bool = false { didSet { updateBackground() } }

	private var isSettingEffectInternally: Bool = false
	override var effect: UIVisualEffect? {
		didSet {
			guard !isSettingEffectInternally else { return }
			cachedEffect = effect
			updateBackground()
		}
	}

	private var cachedEffect: UIVisualEffect?

	private var reducedTransparencyObserver: NSObjectProtocol?

	convenience init() {
		self.init(effect: nil)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(effect: UIVisualEffect?) {
		super.init(effect: effect)
		setup()
	}

	private func setup () {
		cachedEffect = effect
		updateBackground()
	}

	private func updateBackground() {
		isSettingEffectInternally = true
		if isTranslucent && !UIAccessibility.isReduceTransparencyEnabled {
			if effect != cachedEffect { effect = cachedEffect }
			backgroundColor = nil
		} else {
			effect = nil
			backgroundColor = .enaColor(for: .background)
		}
		isSettingEffectInternally = false
	}

	override func willMove(toSuperview newSuperview: UIView?) {
		if nil == newSuperview, let observer = reducedTransparencyObserver {
			NotificationCenter.default.removeObserver(observer, name: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil)
		}
	}

	override func didMoveToSuperview() {
		guard nil == reducedTransparencyObserver else { return }
		reducedTransparencyObserver = NotificationCenter.default.addObserver(forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil, queue: nil, using: { [weak self] _ in
			self?.updateBackground()
		})
	}
}
