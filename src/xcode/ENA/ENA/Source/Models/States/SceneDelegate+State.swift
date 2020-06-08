//
// Created by Hu, Hao on 08.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
//

import Foundation

extension SceneDelegate {
	struct State {
		var exposureManager: ExposureManagerState
		var detectionMode: DetectionMode
		var risk: Risk?
	}
}
