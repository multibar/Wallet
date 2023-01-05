import CoreKit
import Foundation
import InterfaceKit

extension Attributes {
    public static var navigation: Attributes {
        return .attributes(for: .title(size: .medium), color: .xFFFFFF, lineBreak: .byTruncatingMiddle)
    }
}
extension NavigationController.Bar.Style {
    public static var navigation: NavigationController.Bar.Style {
        return NavigationController.Bar.Style(background: .blur(.x151A26),
                                              attributes: .attributes(for: .title(size: .small), color: .xFFFFFF),
                                              separator: .color(.x8B93A1_20))
    }
}
