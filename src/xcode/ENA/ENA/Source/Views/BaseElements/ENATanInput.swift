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
	func tanChanged(isValid: Bool, checksumIsValid: Bool)
}

@IBDesignable
class ENATanInput: UIControl, UIKeyInput {
	@IBInspectable var labelTextColor: UIColor = .enaColor(for: .textPrimary1)
	@IBInspectable var boxColor: UIColor = .enaColor(for: .separator)

	@IBInspectable var fontSize: CGFloat = 30
	@IBInspectable var groups: String = "3,3,4"
	@IBInspectable var forbidden: String = "1,0,I,O,L"

	@IBInspectable var spacing: CGFloat = 3
	@IBInspectable var cornerRadius: CGFloat = 4

	private weak var stackView: UIStackView!
	weak var delegate: ENATanInputDelegate?
	private(set) var text = ""
	var count: Int { text.count }

	var dashes: [Int] { groups.split(separator: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }) }
	var forbiddenArray: [String] { forbidden.split(separator: ",").map(String.init) }
	var digits: Int { dashes.reduce(0) { $0 + $1 } }

	// swiftlint:disable:next empty_count
	var isEmpty: Bool { count == 0 }
	var isValid: Bool { count == digits }
	var inputBlocked: Bool = false

	private var labels: [UILabel] { stackView.arrangedSubviews.compactMap({ $0 as? ENATanInputLabel }) }

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
		stackView.distribution = .fill
		stackView.alignment = .fill

		let font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: fontSize, weight: .bold)

		for (index, digits) in dashes.enumerated() {
			if index > 0 {
				let label = UILabel()
				label.textAlignment = .center
				label.textColor = labelTextColor
				label.font = font
				label.text = "-"
				stackView.addArrangedSubview(label)
			}

			for _ in 0..<digits {
				let label = ENATanInputLabel()
				label.clipsToBounds = true
				label.backgroundColor = boxColor
				label.layer.cornerRadius = cornerRadius
				label.textAlignment = .center
				label.textColor = labelTextColor
				label.font = font
				stackView.addArrangedSubview(label)
			}
		}

		if let firstLabel = labels.first {
			labels[1...].forEach { firstLabel.widthAnchor.constraint(equalTo: $0.widthAnchor).isActive = true }
		}

		addSubview(stackView)
		stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
	}

	func insertText(_ text: String) {
		guard !inputBlocked else {return}
		for character in text {
			guard !isValid else { return }
			let label = labels[count]

			label.text = "\(character.uppercased())"
			self.text += "\(character.uppercased())"
			if let enaInputLabel = label as? ENATanInputLabel {
				if forbiddenArray.contains(String(character.uppercased())) {
					enaInputLabel.isValid = false
					enaInputLabel.textColor = .enaColor(for: .textSemanticRed)
					inputBlocked = true
				} else {
					enaInputLabel.isValid = true
					enaInputLabel.textColor = labelTextColor
				}
			}

		}
		delegate?.tanChanged(isValid: isValid, checksumIsValid: verifyChecksum(input: self.text))
	}

	func deleteBackward() {
		guard !isEmpty else { return }
		inputBlocked = false
		text = String(text[..<text.index(before: text.endIndex)])
		let label = labels[count]
		label.text = ""
		if let enaInputLabel = label as? ENATanInputLabel {
			enaInputLabel.isValid = true
		}
		delegate?.tanChanged(isValid: isValid, checksumIsValid: false)
	}

	func clear() {
		labels.forEach { $0.text = "" }
		text = ""
	}
	
	func verifyChecksum(input:String) -> Bool {
		guard isValid else { return false}
		let start = input.index(input.startIndex, offsetBy: 0)
		let end = input.index(input.startIndex, offsetBy: input.count-2)
		let testString = String(input[start...end])
		return input.last == calculateChecksum(input: testString)
	}
	
	func calculateChecksum(input:String) -> Character {
		let hash = Hasher.sha256(input)
		var checksum = hash[hash.startIndex].uppercased()
		if (checksum == "0") { checksum = "G" }
		else if (checksum == "1") { checksum = "H" }
		return checksum.first!
	}
}

private class ENATanInputLabel: UILabel {
	private let lineWidth: CGFloat = 3

	var isValid: Bool = true { didSet { setNeedsDisplay() } }

	var color: UIColor {
		if isValid {
			if self.text?.isEmpty == nil || self.text == "" {
				return .enaColor(for: .hairline)
			} else {
				return UIColor.clear
			}
		} else {
			return .enaColor(for: .textSemanticRed)
		}

	}

	override func draw(_ rect: CGRect) {
		super.draw(rect)

		guard let context = UIGraphicsGetCurrentContext() else { return }
		context.setLineWidth(lineWidth)
		context.setStrokeColor(color.cgColor)
		context.move(to: CGPoint(x: 0, y: bounds.height - lineWidth / 2))
		context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - lineWidth / 2))
		context.strokePath()
	}
}
