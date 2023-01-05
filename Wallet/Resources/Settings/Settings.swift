import CoreKit

extension Settings {
    public struct App {
        private init() {}
    }
}

extension Settings.App {
    public static var biometry: Bool {
        get { Settings.get(value: Bool.self, for: Settings.Keys.App.biometry) ?? false }
        set { Settings.set(value: newValue, for: Settings.Keys.App.biometry) }
    }
}
