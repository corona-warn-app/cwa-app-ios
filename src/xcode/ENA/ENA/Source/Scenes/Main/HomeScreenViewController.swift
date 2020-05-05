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
    @IBOutlet weak var settingButton: UIButton!
    private let client: Client = MockClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExposureDetection" {
            guard let exposureDetectionVC = segue.destination as? ExposureDetectionViewController else { fatalError() }
            exposureDetectionVC.exposureDetectionService = ExposureDetectionService(delegate: exposureDetectionVC, client: client)
        }
        super.prepare(for: segue, sender: sender)
    }
}

extension HomeScreenViewController {
    private func setupViews(){
        updateButton.applyStyle()
        settingButton.applyStyle()
        
        let frame = circleView.frame
        circleView.layer.cornerRadius = frame.size.height / 2
    }
}

extension HomeScreenViewController {
    
    @IBAction func submitResultDidClick(_ sender: Any) {
        let vc = SelfExposureViewController.initiate(for: .selfExposure)
        vc.exposureSubmissionService = ExposureSubmissionServiceImpl(client: client)
        let naviController = UINavigationController(rootViewController: vc)
        self.present(naviController, animated: true, completion: nil)
    }
    
    @IBAction func exposureNotifcationSettingBtnDidClick(_ sender: Any) {
        let vc = ExposureNotificationSettingViewController.initiate(for: .exposureNotificationSetting)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func settingBtnDidClick(_ sender: Any) {
        let vc = FriendsInviteController.initiate(for: .inviteFriends)
        let naviController = UINavigationController(rootViewController: vc)
        self.present(naviController, animated: true, completion: nil)
    }

    @IBAction func showDeveloperMenu(_ sender: Any) {
        let navigationController = UINavigationController(rootViewController: DeveloperMenuViewController(client: client))
           self.present(navigationController, animated: true, completion: nil)
       }
}

extension UIButton {
    func applyStyle(){
        self.tintColor = UIColor.black
        self.backgroundColor = UIColor.gray
    }
}
