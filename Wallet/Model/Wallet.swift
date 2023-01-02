import UIKit
import CoreKit

extension Wallet.Location {
    internal var icon: UIImage? {
        switch self {
        case .cloud:
            return .location_cloud
        case .keychain:
            return .location_keychain
        }
    }
}
