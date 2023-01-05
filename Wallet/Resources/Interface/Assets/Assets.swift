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
    internal static var bar_edit: UIImage? {
        return .asset("icon/bar/edit")
    }
    internal static var bar_scan: UIImage? {
        return .asset("icon/bar/scan")
    }
    internal static var bar_trash: UIImage? {
        return .asset("icon/bar/trash")
    }
    internal static var bar_profile: UIImage? {
        return .asset("icon/bar/profile")
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
    internal static var keyboard_delete: UIImage? {
        return .asset("icon/keyboard/delete")
    }
    internal static var biometry_faceID: UIImage? {
        return .asset("icon/biometry/faceID")
    }
    internal static var biometry_touchID: UIImage? {
        return .asset("icon/biometry/touchID")
    }
    internal static var option_reset: UIImage? {
        return .asset("icon/option/reset")
    }
    internal static var option_USD: UIImage? {
        return .asset("icon/option/USD")
    }
    internal static var option_EUR: UIImage? {
        return .asset("icon/option/EUR")
    }
    internal static var option_faceID: UIImage? {
        return .asset("icon/option/faceID")
    }
    internal static var option_touchID: UIImage? {
        return .asset("icon/option/touchID")
    }
    internal static var footprint_coin: UIImage? {
        return .asset("icon/footprint/TON")
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
