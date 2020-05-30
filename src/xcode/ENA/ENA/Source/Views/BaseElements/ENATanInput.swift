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

protocol ENATanInputDelegate: AnyObject {
	func tanChanged(isValid: Bool)
}

@IBDesignable
class ENATanInput: UIControl, UIKeyInput {
	@IBInspectable var textColor: UIColor = UIColor.preferredColor(for: .textPrimary1)
	@IBInspectable var boxColor: UIColor = UIColor.preferredColor(for: .backgroundSecondary)
	
	@IBInspectable var fontSize: CGFloat = 30
	@IBInspectable var digits: Int = 7
	
	@IBInspectable var spacing: CGFloat = 8
	@IBInspectable var cornerRadius: CGFloat = 4
	
	private weak var stackView: UIStackView!
	weak var delegate: ENATanInputDelegate?
	private(set) var text = ""
	var count: Int { text.count }
	
	// swiftlint:disable:next empty_count
	var isEmpty: Bool { count == 0 }
	var isValid: Bool { count == digits }
	
	override var canBecomeFirstResponder: Bool { true }
	
	var keyboardType: UIKeyboardType = .namePhonePad
	
	var hasText: Bool { !text.isEmpty }
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		
		backgroundColor = UIColor.preferredColor(for: .backgroundSecondary)
		
		let label = UILabel(frame: .zero)
		label.text = String(describing: ENATanInput.self)
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		label.sizeToFit()
		
		addSubview(label)
		label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		label.center = CGPoint(x: (frame.maxX - frame.minX) / 2, y: (frame.maxY - frame.minY) / 2)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		guard stackView == nil else { return }
		addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		let stackView = UIStackView()
		self.stackView = stackView
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.isUserInteractionEnabled = false
		stackView.spacing = spacing
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.alignment = .fill
		
		let font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: fontSize, weight: .bold)
		for _ in 0 ..< digits {
			let label = UILabel()
			label.clipsToBounds = true
			label.backgroundColor = boxColor
			label.layer.cornerRadius = cornerRadius
			label.textAlignment = .center
			label.font = font
			stackView.addArrangedSubview(label)
		}
		
		addSubview(stackView)
		stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
	}
	
	func insertText(_ text: String) {
		for character in text {
			guard !isValid else { return }
			let label = stackView.arrangedSubviews[count] as? UILabel
			label?.text = "\(character)"
			self.text += "\(character)"
		}
		delegate?.tanChanged(isValid: isValid)
	}
	
	func deleteBackward() {
		guard !isEmpty else { return }
		text = String(text[..<text.index(before: text.endIndex)])
		let label = stackView.arrangedSubviews[count] as? UILabel
		label?.text = ""
		delegate?.tanChanged(isValid: isValid)
	}
	
	func clear() {
		for i in 0 ..< text.count {
			(stackView.arrangedSubviews[i] as? UILabel)?.text = ""
		}
		text = ""
	}
}
