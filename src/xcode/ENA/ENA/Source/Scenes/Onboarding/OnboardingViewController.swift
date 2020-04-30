//
//  OnboardingViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit


class OnboardingViewController: UIViewController {
    
    @IBOutlet var enLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let p = PageViewController()
            self.present(p, animated: false, completion: nil)
        }
    }
    
    @IBAction func onboardingTapped(_ sender: Any) {
        UserSettings.onboardingWasShown = true
        
        let notification = Notification(name: .onboardingFlagDidChange)
        NotificationCenter.default.post(notification)
    }
    
}
