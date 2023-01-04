import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Button: Cell {
        public override class var identifier: String {
            return "buttonCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(top: 0, left: 32, right: 32, bottom: 0)
        }
        public private(set) var active = true
        
        private let icon = UIImageView()
        private let title = Label()
        
        private var action: Store.Item.Button.Action?
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            icon.clear()
            title.clear()
        }
        public func set(active: Bool, animated: Bool = true) {
            self.active = active
            guard let action else { return }
            let values = values(for: action, active: active)
            View.animate(duration: animated ? 0.5 : 0.0, spring: 1.0, velocity: 1.0) {
                self.content.alpha = active ? 1.0 : 0.33
                self.content.color = active ? values.color : .xFFFFFF_05
            }
        }
        public func configure(with action: Store.Item.Button.Action, active: Bool = true) {
            self.action = action
            let values = values(for: action, active: active)
            self.icon.image = values.icon
            self.icon.tint = values.tint
            self.title.set(text: values.title, attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
            self.content.color = values.color
            self.set(active: values.active, animated: false)
        }
        
        public override func setup() {
            super.setup()
            content.corner(radius: 12)
            layout()
        }
        private func layout() {
            icon.auto = false
            title.auto = false
            
            content.add(icon)
            content.add(title)
            
            icon.aspect(ratio: 24)
            icon.centerY(to: content.centerY)
            icon.right(to: content.right, constant: 16)
            title.box(in: content)
        }
        
        private func values(for action: Store.Item.Button.Action, active: Bool) -> (icon: UIImage?, tint: UIColor?, title: String?, color: UIColor?, active: Bool) {
            var icon: UIImage?
            var tint: UIColor?
            var title: String?
            var color: UIColor?
            var active = active
            switch action {
            case .process:
                title = "DONE"
                color = .x58ABF5
            case .route(let route):
                switch route.destination {
                case .add(let add):
                    switch add {
                    case .store(let store):
                        switch store {
                        case .location:
                            title = "STORE"
                            color = .xFFFFFF_05
                        case .recovery(_, let location):
                            switch location {
                            case .cloud:
                                let authorized = Network.shared.state == .authorized
                                icon = authorized ? .location_cloud?.template : .icon_lock
                                tint = authorized ? .xFFFFFF : nil
                                title = "CLOUD"
                                color = authorized ? .x58ABF5 : .xFFFFFF_05
                                active = authorized
                            case .keychain:
                                icon = .location_keychain
                                title = "KEYCHAIN"
                                color = .xFFFFFF_05
                            }
                        }
                    case .create:
                        title = "CREATE"
                        color = .x58ABF5
                    case .import:
                        title = "IMPORT"
                        color = .xFFFFFF_05
                    default:
                        break
                    }
                default:
                    break
                }
            }
            return (icon: icon, tint: tint, title: title, color: color, active: active)
        }
    }
}
