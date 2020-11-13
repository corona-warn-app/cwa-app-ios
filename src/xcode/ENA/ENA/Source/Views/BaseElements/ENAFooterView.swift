//
// 🦠 Corona-Warn-App
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
