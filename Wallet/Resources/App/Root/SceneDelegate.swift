import UIKit

internal class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?

    internal func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        setup(scene: scene)
    }
    internal func sceneDidDisconnect(_ scene: UIScene) {}
    internal func sceneDidBecomeActive(_ scene: UIScene) {}
    internal func sceneWillResignActive(_ scene: UIScene) {}
    internal func sceneWillEnterForeground(_ scene: UIScene) {}
    internal func sceneDidEnterBackground(_ scene: UIScene) {}
    
    private func setup(scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowScene = windowScene
        window.makeKeyAndVisible()
        (UIApplication.shared.delegate as? AppDelegate)?.windows.append(window)
        self.window = window
        window.rootViewController = TabViewController()
    }
}

