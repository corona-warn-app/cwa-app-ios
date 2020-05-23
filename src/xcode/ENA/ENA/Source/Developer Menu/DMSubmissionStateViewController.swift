//
//  DMSubmissionStateViewController.swift
//  ENA
//
//  Created by Kienle, Christian on 23.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

protocol DMSubmissionStateViewControllerDelegate: AnyObject {
    func submissionStateViewController(
        _ controller: DMSubmissionStateViewController,
        getDiagnosisKeys completionHandler: @escaping ENGetDiagnosisKeysHandler
    )
}

/// This controller allows you to check if a previous submission of keys successfully ended up in the backend.
final class DMSubmissionStateViewController: UITableViewController {
    init(
        client: Client,
        delegate: DMSubmissionStateViewControllerDelegate
    ) {
        self.client = client
        self.delegate = delegate
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    private weak var delegate: DMSubmissionStateViewControllerDelegate?
    private let client: Client

    // MARK: UIViewController
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Do It",
            style: .plain,
            target: self,
            action: #selector(doIt)
        )
    }

    @objc
    func doIt() {
        let group = DispatchGroup()

        group.enter()
        var allPackages = [SAPKeyPackage]()
        client.fetch { result in
            allPackages = result.allKeyPackages
            group.leave()
        }

        var localKeys = [ENTemporaryExposureKey]()

        group.enter()
        delegate?.submissionStateViewController(self) { keys, error in
            precondition(Thread.isMainThread)
            defer { group.leave() }

            if let error = error {
                self.present(
                    UIAlertController(
                        title: "Failed to get local diagnosis keys",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    ),
                    animated: true
                )
                return
            }
            localKeys = keys ?? []
        }

        group.notify(queue: .main) {
            var remoteKeys = [Apple_TemporaryExposureKey]()
            do {
                for package in allPackages {
                    remoteKeys.append(contentsOf: try package.keys())
                }
            } catch {
                print(error)
            }
            let localKeysFoundRemotly = localKeys.filter { remoteKeys.containsKey($0) }
            let foundOwnKey = localKeysFoundRemotly.isEmpty == false
            let allLocalKeysFoundRemotly = localKeys.count == localKeysFoundRemotly.count
            print("localKeysFoundRemotly: \(localKeysFoundRemotly)")
            print("foundOwnKey: \(foundOwnKey)")
            print("allLocalKeysFoundRemotly: \(allLocalKeysFoundRemotly)")
        }
    }
}

private extension Data {
    // swiftlint:disable:next force_unwrapping
    static let binHeader = "EK Export v1    ".data(using: .utf8)!

    var withoutBinHeader: Data {
        let headerRange = startIndex..<Data.binHeader.count

        guard subdata(in: headerRange) == Data.binHeader else {
            return self
        }
        return subdata(in: headerRange.endIndex..<endIndex)
    }
}

extension SAPKeyPackage {
    var binProtobufData: Data {
        bin.withoutBinHeader
    }

    func keys() throws -> [Apple_TemporaryExposureKey] {
        let data = binProtobufData
        let export = try Apple_TemporaryExposureKeyExport(serializedData: data)
        return export.keys
    }
}

private extension Array where Element == Apple_TemporaryExposureKey {
    func containsKey(_ key: ENTemporaryExposureKey) -> Bool {
        contains { appleKey in
            appleKey.keyData == key.keyData
        }
    }
}
