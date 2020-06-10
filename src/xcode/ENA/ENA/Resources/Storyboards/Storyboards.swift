// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum DynamicTableViewControllerFake: StoryboardType {
    internal static let storyboardName = "DynamicTableViewControllerFake"

    internal static let dynamicTableViewController = SceneType<ENA.DynamicTableViewController>(storyboard: DynamicTableViewControllerFake.self, identifier: "DynamicTableViewController")
  }
  internal enum ExposureDetection: StoryboardType {
    internal static let storyboardName = "ExposureDetection"

    internal static let initialScene = InitialSceneType<ENA.ExposureDetectionViewController>(storyboard: ExposureDetection.self)
  }
  internal enum ExposureNotificationSetting: StoryboardType {
    internal static let storyboardName = "ExposureNotificationSetting"

    internal static let initialScene = InitialSceneType<ENA.ExposureNotificationSettingViewController>(storyboard: ExposureNotificationSetting.self)

    internal static let exposureNotificationSettingViewController = SceneType<ENA.ExposureNotificationSettingViewController>(storyboard: ExposureNotificationSetting.self, identifier: "ExposureNotificationSettingViewController")
  }
  internal enum ExposureSubmission: StoryboardType {
    internal static let storyboardName = "ExposureSubmission"

    internal static let initialScene = InitialSceneType<ENA.ExposureSubmissionNavigationController>(storyboard: ExposureSubmission.self)

    internal static let exposureSubmissionHotlineViewController = SceneType<ENA.ExposureSubmissionHotlineViewController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionHotlineViewController")

    internal static let exposureSubmissionIntroViewController = SceneType<ENA.ExposureSubmissionIntroViewController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionIntroViewController")

    internal static let exposureSubmissionNavigationController = SceneType<ENA.ExposureSubmissionNavigationController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionNavigationController")

    internal static let exposureSubmissionOverviewViewController = SceneType<ENA.ExposureSubmissionOverviewViewController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionOverviewViewController")

    internal static let exposureSubmissionSuccessViewController = SceneType<ENA.ExposureSubmissionSuccessViewController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionSuccessViewController")

    internal static let exposureSubmissionTanInputViewController = SceneType<ENA.ExposureSubmissionTanInputViewController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionTanInputViewController")

    internal static let exposureSubmissionTestResultViewController = SceneType<ENA.ExposureSubmissionTestResultViewController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionTestResultViewController")

    internal static let exposureSubmissionWarnOthersViewController = SceneType<ENA.ExposureSubmissionWarnOthersViewController>(storyboard: ExposureSubmission.self, identifier: "ExposureSubmissionWarnOthersViewController")
  }
  internal enum Home: StoryboardType {
    internal static let storyboardName = "Home"

    internal static let initialScene = InitialSceneType<ENA.HomeViewController>(storyboard: Home.self)

    internal static let homeViewController = SceneType<ENA.HomeViewController>(storyboard: Home.self, identifier: "HomeViewController")
  }
  internal enum InviteFriends: StoryboardType {
    internal static let storyboardName = "InviteFriends"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: InviteFriends.self)

    internal static let friendsInviteController = SceneType<ENA.FriendsInviteController>(storyboard: InviteFriends.self, identifier: "FriendsInviteController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Onboarding: StoryboardType {
    internal static let storyboardName = "Onboarding"

    internal static let initialScene = InitialSceneType<ENA.OnboardingInfoViewController>(storyboard: Onboarding.self)

    internal static let onboardingInfoViewController = SceneType<ENA.OnboardingInfoViewController>(storyboard: Onboarding.self, identifier: "OnboardingInfoViewController")
  }
  internal enum RiskLegend: StoryboardType {
    internal static let storyboardName = "RiskLegend"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: RiskLegend.self)
  }
  internal enum Settings: StoryboardType {
    internal static let storyboardName = "Settings"

    internal static let resetViewController = SceneType<ENA.ResetViewController>(storyboard: Settings.self, identifier: "ResetViewController")

    internal static let settingsViewController = SceneType<ENA.SettingsViewController>(storyboard: Settings.self, identifier: "SettingsViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
