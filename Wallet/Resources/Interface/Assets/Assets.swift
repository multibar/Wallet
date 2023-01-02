import UIKit
import CoreKit

extension UIImage {
    internal static var icon_lock: UIImage? {
        return .asset("icon/common/lock")
    }
    internal static var icon_market: UIImage? {
        return .asset("icon/common/market")
    }
    internal static var chevron_left: UIImage? {
        return .asset("icon/chevron/left")
    }
    internal static var chevron_right: UIImage? {
        return .asset("icon/chevron/right")
    }
    internal static var location_cloud: UIImage? {
        return .asset("icon/location/cloud")
    }
    internal static var location_keychain: UIImage? {
        return .asset("icon/location/keychain")
    }
    internal static var arrow_up: UIImage? {
        return .asset("icon/arrow/up")
    }
    internal static var arrow_down: UIImage? {
        return .asset("icon/arrow/down")
    }
    internal static var bar_add: UIImage? {
        return .asset("icon/bar/add")
    }
    internal static var bar_scan: UIImage? {
        return .asset("icon/bar/scan")
    }
    internal static var bar_settings: UIImage? {
        return .asset("icon/bar/settings")
    }
    internal static var perk_key: UIImage? {
        return .asset("icon/perks/key")
    }
    internal static var perk_wallet: UIImage? {
        return .asset("icon/perks/wallet")
    }
}
extension UIImage {
    internal var template: UIImage {
        return withRenderingMode(.alwaysTemplate)
    }
    internal static func symbol(_ name: String, rendering mode: UIImage.RenderingMode = .alwaysOriginal) -> UIImage? {
        return UIImage(systemName: name)?.withRenderingMode(mode)
    }
    fileprivate static func asset(_ name: String) -> UIImage? {
        return UIImage(named: name)
    }
}
extension Coin.Perk {
    internal var icon: UIImage? {
        switch self {
        case .key:
            return .asset("icon/perks/key")
        case .wallet:
            return .asset("icon/perks/wallet")
        }
    }
}
