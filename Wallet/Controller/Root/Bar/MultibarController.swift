import UIKit
import CoreKit
import NetworkKit
import InterfaceKit
import OrderedCollections

public protocol MultibarController: ViewController, PasscodeDelegate {
    var position: Multibar.Position { get }
    var viewController: ViewController? { get }
    var viewControllers: [ViewController] { get set }
    func maximize()
    func minimize()
    func set(loading: Bool, animated: Bool, completion: (() -> Void)?)
}

public class Multibar: ListViewController {
    public weak var controller: MultibarController?
    
    public override var navBarStyle: NavigationController.Bar.Style { .multibar }
    public override var navBarItems: [NavigationController.Bar.Item] { [minimize] }
    public override var navBarHidden: Bool { controller?.position != .top }
    public override var background: UIColor { .clear }
            
    public func set(selected route: Route) {
        guard let section = list.source.sections.first(where: {$0.template == .tabs}) else { return }
        section.items.forEach({
            if $0.route == route {
                list.select(item: $0, position: nil, animated: true)
            } else {
                list.deselect(item: $0, animated: true)
            }
        })
    }
    public override func receive(order: Store.Order, from store: Store) async {
        switch await order.status {
        case .created, .accepted:
            controller?.set(loading: true, animated: false, completion: nil)
        case .cancelled, .completed, .failed:
            controller?.set(loading: false, animated: true, completion: nil)
        }
        await super.receive(order: order, from: store)
        let sections = await order.sections.filter({$0.template == .tabs}).flatMap({$0.items})
        controller?.viewControllers = sections.compactMap({
            switch $0.template {
            case .tab(let tab):
                switch tab.route.destination {
                case .wallets:
                    return NavigationController(viewController: ListViewController(route: tab.route, load: false))
                default:
                    return nil
                }
            default:
                return nil
            }
        })
    }
    public override func process(route: Route) {
        switch route.destination {
        //handle embedded cases
        default:
            controller?.process(route: route)
        }
    }
}
extension Multibar {
    public func reset(for position: Multibar.Position) {
        if position.descended { navigation?.back(to: .root) }
        list.reinset()
        navBar?.set(hidden: navBarHidden, animated: false)
        scroll?.offset(to: .point(x: 0, y: -(scroll?.insets.top ?? 0)))
        (list.configuredCells + list.configuredBoundaries).forEach { view in
            switch view {
            case let cell as Permanent:
                cell.alpha = position.descended ? cell.permanent ? 1.0 : 0.0 : 1.0
            default:
                view.alpha = position.descended ? 0.0 : 1.0
            }
        }
    }
}
extension Multibar {
    public enum Position {
        case top
        case middle
        case bottom
        case headed
        case hidden
        
        public var descended: Bool {
            switch self {
            case .hidden, .headed, .bottom:
                return true
            default:
                return false
            }
        }
        public func context(for view: UIView, traits: UITraitCollection) -> Context {
            let safe = view.safeAreaInsets
            let compact = traits.vertical == .compact
            switch self {
            case .top:
                let scale = (view.frame.width - 32) / view.frame.width
                let top = compact ? -view.frame.height : -view.frame.height + safe.top + 8
                let compensated = ((view.frame.height - (view.frame.height * scale)) / 2)
                let offset = -(compensated - (view.frame.height - abs(top)) + 8)
                return Context(top: top, grab: 8, scale: scale, offset: offset, radius: .device)
            case .middle:
                return Context(top: -view.frame.height/2, grab: -8, scale: 1, offset: 0, radius: .device)
            case .bottom:
                return Context(top: minimal(for: view), grab: -8, scale: 1, offset: 0, radius: .device)
            case .headed:
                return Context(top: -56, grab: -8, scale: 0, offset: 1, radius: .device)
            case .hidden:
                return Context(top: 0, grab: 8, scale: 0, offset: 1, radius: .device)
            }
        }
        public func minimal(for view: UIView) -> CGFloat {
            switch self {
            case .hidden:
                return 0
            default:
                let safe = view.safeAreaInsets
                let bottom = safe.bottom == 0.0 ? 0.0 : 16.0
                return -bottom - 56.0 - 16.0 - 16.0
            }
        }
    }
    public enum Preference {
        case none
        case soft
        case linear
        
        public var none: Bool {
            switch self {
            case .none:
                return true
            default:
                return false
            }
        }
        public var soft: Bool {
            switch self {
            case .soft:
                return true
            default:
                return false
            }
        }
        public var linear: Bool {
            switch self {
            case .linear:
                return true
            default:
                return false
            }
        }
    }
    public struct Context {
        public let top: CGFloat
        public let grab: CGFloat
        public let scale: CGFloat
        public let offset: CGFloat
        public let radius: CGFloat
        
        public static var zero: Context {
            return Context(top: 0,
                           grab: 0,
                           scale: 0,
                           offset: 0,
                           radius: 0)
        }
    }
}
extension Multibar {
    fileprivate var minimize: NavigationController.Bar.Item {
        return .back(direction: .down) { [weak self] in
            self?.controller?.minimize()
        }
    }
}
