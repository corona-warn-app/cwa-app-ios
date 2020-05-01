//
//  MainViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var circleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()

    }
    
    

    @IBAction func settingButtonDidClick(_ sender: Any) {
        let vc = ExposureNotificationSettingViewController.initiate(for: .exposureNotificationSetting)
        self.present(vc, animated: true, completion: nil)        
    }
    
}

extension HomeScreenViewController {
    private func setupViews(){
        updateButton.tintColor = UIColor.black
        updateButton.backgroundColor = UIColor.gray
        let frame = circleView.frame
        circleView.layer.cornerRadius = frame.size.height / 2
        
    }
}
