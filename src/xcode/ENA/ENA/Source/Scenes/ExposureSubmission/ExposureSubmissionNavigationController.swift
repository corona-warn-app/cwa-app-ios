//
//  ExposureSubmissionNavigationController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 19.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class ExposureSubmissionNavigationItem: UINavigationItem {
	@IBInspectable var titleColor: UIColor?
}

protocol ExposureSubmissionNavigationControllerChild: class {
	var bottomView: UIView? { get }
//	TODO var bottomButtonText: String { get }
	func didTapBottomButton()
}

extension ExposureSubmissionNavigationControllerChild where Self: UIViewController {
	var bottomView: UIView? { (navigationController as? ExposureSubmissionNavigationController)?.bottomView }
}

class ExposureSubmissionNavigationController: UINavigationController, UINavigationControllerDelegate {
	private var keyboardWillShowObserver: NSObjectProtocol?
	private var keyboardWillHideObserver: NSObjectProtocol?
	
	private(set) var isBottomViewHidden: Bool = true
	private var isKeyboardHidden: Bool = true
	private var keyboardWindowFrame: CGRect?
	
	private(set) var bottomView: UIView!
	private var bottomViewTopConstraint: NSLayoutConstraint!
    private var exposureSubmissionService: ExposureSubmissionService?
    private var client: Client?
    
    // MARK: - Initializers.
    init?(
        coder: NSCoder,
        exposureSubmissionService: ExposureSubmissionService,
        client: Client
    ) {
        super.init(coder: coder)
        self.exposureSubmissionService = exposureSubmissionService
        self.client = client
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .done, target: self, action: #selector(close))
		barButtonItem.tintColor = UIColor.preferredColor(for: .separator)
		navigationItem.rightBarButtonItem = barButtonItem
		
		setupBottomView()
		
		if topViewController?.hidesBottomBarWhenPushed ?? false {
			setBottomViewHidden(true, animated: false)
		}
		
		self.delegate = self
	}
    
    func getExposureSubmissionService() -> ExposureSubmissionService? {
        return exposureSubmissionService
    }
	
    func getClient() -> Client? {
        return client
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		applyDefaultRightBarButtonItem(to: topViewController)
		applyNavigationBarItem(of: topViewController)
		
		keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
			self.isKeyboardHidden = false
			self.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self.updateBottomSafeAreaInset(animated: true)

		}
		
		keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
			self.isKeyboardHidden = true
			self.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self.updateBottomSafeAreaInset(animated: true)
		}
		
		keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { notification in
			self.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self.updateBottomSafeAreaInset(animated: true)
		}
	}
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationCenter.default.removeObserver(keyboardWillHideObserver as Any, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(keyboardWillHideObserver as Any, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	
	private func applyDefaultRightBarButtonItem(to viewController: UIViewController?) {
		if let viewController = viewController, nil == viewController.navigationItem.rightBarButtonItem {
			viewController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem
		}
	}
	
	
	private func applyNavigationBarItem(of viewController: UIViewController?) {
		if let viewController = viewController,
			let navigationItem = viewController.navigationItem as? ExposureSubmissionNavigationItem,
			let titleColor = navigationItem.titleColor {
			navigationBar.largeTitleTextAttributes = [:]
			navigationBar.largeTitleTextAttributes?[NSAttributedString.Key.foregroundColor] = titleColor
		} else {
			navigationBar.largeTitleTextAttributes?.removeValue(forKey: NSAttributedString.Key.foregroundColor)
		}
	}
	
	
	func setBottomViewHidden(_ hidden: Bool, animated: Bool) {
		guard hidden != isBottomViewHidden else { return }
		isBottomViewHidden = hidden
		
		updateBottomSafeAreaInset(animated: animated)
		bottomViewTopConstraint.isActive = hidden
		
		if animated { CATransaction.begin() }

		if isBottomViewHidden {
			self.bottomView.frame.origin.y = self.view.frame.height
			self.bottomView.frame.size.height = 0
		} else {
			self.bottomView.frame.origin.y = self.view.frame.height - self.view.safeAreaInsets.bottom
			self.bottomView.frame.size.height = self.view.safeAreaInsets.bottom
		}
		
		bottomView.layoutIfNeeded()
		
		if animated { CATransaction.commit() }
		
	}
	
	
	private func updateBottomSafeAreaInset(animated: Bool = false) {
		let baseInset = self.view.safeAreaInsets.bottom - self.additionalSafeAreaInsets.bottom
		var bottomInset: CGFloat = 0
		
		if !isBottomViewHidden { bottomInset += 90 }
		
		if !isKeyboardHidden {
			if let keyboardWindowFrame = keyboardWindowFrame {
				let localOrigin = self.view.convert(keyboardWindowFrame.origin, from: nil)
				bottomInset += self.view.frame.height - localOrigin.y - baseInset
			}
		}
		
		self.additionalSafeAreaInsets.bottom = bottomInset
		
		if animated {
			CATransaction.begin()
			topViewController?.view.layoutIfNeeded()
			CATransaction.commit()
		}
	}
	
	
	@objc
	func close() {
		dismiss(animated: true)
	}
}


extension ExposureSubmissionNavigationController {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		applyDefaultRightBarButtonItem(to: viewController)
		applyNavigationBarItem(of: viewController)
		
		let isBottomViewHidden = self.isBottomViewHidden
		
		transitionCoordinator?.animate(alongsideTransition: { context in
			self.setBottomViewHidden(viewController.hidesBottomBarWhenPushed, animated: false)
		}, completion: { context in
			if context.isCancelled {
				self.setBottomViewHidden(isBottomViewHidden, animated: true)
				self.applyNavigationBarItem(of: self.topViewController)
			}
		})
	}
}


extension ExposureSubmissionNavigationController {
	private func setupBottomView() {
		let view = UIView()
		view.backgroundColor = .white
		view.insetsLayoutMarginsFromSafeArea = true
		view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(view)
		view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		let bottomConstraint = view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		bottomConstraint.isActive = true
		bottomConstraint.priority = .defaultHigh
		bottomViewTopConstraint = view.topAnchor.constraint(equalTo: self.view.bottomAnchor)
		
		let button = ENAButton(type: .system)
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 17, weight: .semibold)
		button.setTitle("Test Button", for: .normal)
		
		button.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(button)
		button.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
		button.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
		button.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
		button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 90).isActive = true
		button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
		bottomView = view
		button.addTarget(self, action: #selector(didTapButton), for: .primaryActionTriggered)
		setBottomViewHidden(false, animated: false)
	}

	@objc
	private func didTapButton() {
		(topViewController as? ExposureSubmissionNavigationControllerChild)?.didTapBottomButton()
	}
}
