//
//  ENATanInput.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 19.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class ENATanInput: UIControl, UIKeyInput {
	@IBInspectable var textColor: UIColor = .lightGray
	@IBInspectable var boxColor: UIColor = .systemGray
	
	@IBInspectable var fontSize: CGFloat = 30
	@IBInspectable var digits: Int = 4
	
	@IBInspectable var spacing: CGFloat = 8
	@IBInspectable var cornerRadius: CGFloat = 8
	
	
	private weak var stackView: UIStackView!
	
	private(set) var text: String = ""
	var count: Int { text.count }
	
	// swiftlint:disable:next empty_count
	var isEmpty: Bool { count == 0 }
	var isValid: Bool { count == digits }
	
	
	override var canBecomeFirstResponder: Bool { true }
	
	var keyboardType: UIKeyboardType = .numberPad
	
	var hasText: Bool { !text.isEmpty }
	
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		
		backgroundColor = UIColor(red: 0.75, green: 0.85, blue: 1, alpha: 1)
		
		let label = UILabel(frame: .zero)
		label.text = String(describing: ENATanInput.self)
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		label.sizeToFit()
		
		addSubview(label)
		label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		label.center = CGPoint(x: (frame.maxX - frame.minX) / 2, y: (frame.maxY - frame.minY) / 2)
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	
	private func setup() {
		guard nil == stackView else { return }
		addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
		
		self.translatesAutoresizingMaskIntoConstraints = false
		
		let stackView = UIStackView()
		self.stackView = stackView
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.isUserInteractionEnabled = false
		stackView.spacing = self.spacing
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.alignment = .fill
		
		let font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: self.fontSize, weight: .bold)
		for _ in 0..<self.digits {
			let label = UILabel()
			label.clipsToBounds = true
			label.backgroundColor = self.boxColor
			label.layer.cornerRadius = self.cornerRadius
			label.textAlignment = .center
			label.font = font
			stackView.addArrangedSubview(label)
		}
		
		self.addSubview(stackView)
		stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
	}
	
	
	func insertText(_ text: String) {
		for character in text {
			guard !isValid else { return }
			let label = self.stackView.arrangedSubviews[self.count] as? UILabel
			label?.text = "\(character)"
			self.text += "\(character)"
		}
	}
	
	
	func deleteBackward() {
		guard !self.isEmpty else { return }
		self.text = String(self.text[..<self.text.index(before: self.text.endIndex)])
		let label = self.stackView.arrangedSubviews[self.count] as? UILabel
		label?.text = ""
	}
	
	
	func clear() {
		for i in 0..<self.text.count {
			(self.stackView.arrangedSubviews[i] as? UILabel)?.text = ""
		}
		self.text = ""
	}
}
