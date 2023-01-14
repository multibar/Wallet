import CoreKit
import Foundation
import InterfaceKit

extension Attributes {
    public static var navigation: Attributes {
        return .attributes(for: .title(size: .medium), color: .xFFFFFF, lineBreak: .byTruncatingMiddle)
    }
}
extension NavigationController.Bar.Style {
    public static func dynamic(for viewController: ViewController) -> NavigationController.Bar.Style {
        return viewController.navigation?.rootViewController is Multibar ? .multibar : .navigation
    }
    public static var navigation: NavigationController.Bar.Style {
        return NavigationController.Bar.Style(background: .blur(.x151A26),
                                              attributes: .attributes(for: .title(size: .small), color: .xFFFFFF),
                                              separator: .color(.x8B93A1_20))
    }
    public static var multibar: NavigationController.Bar.Style {
        let navigation = NavigationController.Bar.Style.navigation
        return NavigationController.Bar.Style(background: navigation.background,
                                              attributes: navigation.attributes,
                                              separator: navigation.separator,
                                              size: .clipped,
                                              insets: navigation.insets,
                                              spacing: navigation.spacing,
                                              fill: navigation.fill)
    }
}
