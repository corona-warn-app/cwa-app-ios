//
//  SettingsViewExample.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 24.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//


import SwiftUI

struct SettingsViewExample: View {
    @EnvironmentObject var settings: SettingsStoreExample

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications settings")) {
                    Toggle(isOn: $settings.isNotificationEnabled) {
                        Text("Notification:")
                    }
                }

                Section(header: Text("Sleep tracking settings")) {
                    Toggle(isOn: $settings.isSleepTrackingEnabled) {
                        Text("Sleep tracking:")
                    }

                    Picker(
                        selection: $settings.sleepTrackingMode,
                        label: Text("Sleep tracking mode")
                    ) {
                        ForEach(SettingsStoreExample.SleepTrackingMode.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }

                    Stepper(value: $settings.sleepGoal, in: 6...12) {
                        Text("Sleep goal is \(settings.sleepGoal) hours")
                    }
                }

                if !settings.isPro {
                    Section {
                        Button(action: {
                            self.settings.unlockPro()
                        }) {
                            Text("Unlock PRO")
                        }

                        Button(action: {
                            self.settings.restorePurchase()
                        }) {
                            Text("Restore purchase")
                        }
                    }
                }
                }
                .navigationBarTitle(Text("Settings"))
        }
    }
}
