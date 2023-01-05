import UIKit
import CoreKit
import NetworkKit
import InterfaceKit
import UserNotifications

@main
internal class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var windows: [UIWindow] = []
    internal var route: Route?
    internal weak var router: Router?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bridges()
        return true
    }
    internal func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    internal func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    internal func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        Workstation.shared.backgroundCompletion = completionHandler
    }
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let router else { return false }
        router.process(route: Route(with: url.string))
        return true
    }
}

extension AppDelegate {
    private func bridges() {
        Core.shared.initialize(with: self)
        Network.shared.initialize(with: configuration)
        Interface.shared.initialize()
    }
    private func settings() {
        switch System.Device.biometry {
        case .none, .unknown:
            Settings.App.biometry = false
        default:
            break
        }
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    internal func requestNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {_, _ in}
        UIApplication.shared.registerForRemoteNotifications()
    }
    internal func notifications() async -> Notifications.State {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .unknown
        case .denied:        return .denied
        case .authorized:    return .authorized
        case .provisional:   return .provisional
        case .ephemeral:     return .ephemeral
        default:             return .unknown
        }
    }
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let info = response.notification.request.content.userInfo as? [String: AnyObject],
              let route = info["route"] as? String
        else { return }
        guard let router else {
            self.route = Route(with: route)
            return
        }
        router.process(route: Route(with: route))
    }
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner])
        } else {
            completionHandler([.alert])
        }
    }
}
extension AppDelegate: AppBridge {
    internal func app(state: CoreKit.System.App.State) {
        switch state {
        case .willEnterForeground:
            settings()
        default:
            break
        }
        self.windows.forEach({($0.rootViewController as? TabViewController)?.app(state: state)})
    }
    internal func user(state: System.User.State) {
        log(event: "User state did change to \(state)")
    }
}
extension AppDelegate {
    fileprivate var configuration: Network.Configuration {
        return Network.Configuration(firebase: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"))
    }
}
