import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Tab: Cell {
        public override class var identifier: String {
            return "tabCell"
        }
        
        private let icon = Icon()
        private var tab: Store.Item.Tab?
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            tab = nil
            icon.clear()
        }
        
        public func configure(with tab: Store.Item.Tab) {
            self.tab = tab
            self.icon.color = .xEEEFEF
            switch tab {
            case .add:
                icon.set(image: .bar_add)
            case .settings:
                icon.set(image: .bar_settings)
            case .coin(let coin):
                icon.load(from: coin.icons?.small?.url)
            }
        }
        public override func set(selected: Bool, animated: Bool = true) {
            View.animate(duration: 0.5,
                         spring: 1.0,
                         velocity: 0.5,
                         options: [.allowUserInteraction]) {
                self.content.transform = selected ? .scale(to: 1.1) : .identity
                selected ? self.shadow(color: .xEEEFEF, opacity: 0.5, offset: .zero, radius: 6) : self.removeShadow()
            }
        }
        public override func set(highlighted: Bool, animated: Bool = true) {
            let selected = self.selected
            View.animate(duration: 0.5,
                         spring: 1.0,
                         velocity: 0.5,
                         options: [.allowUserInteraction]) {
                self.content.transform = highlighted ? .scale(to: 0.9) : selected ? .scale(to: 1.1) : .identity
                selected ? self.shadow(color: .xEEEFEF, opacity: 0.5, offset: .zero, radius: 6) : self.removeShadow()
            }
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            content.corner(radius: 16)
        }
        private func layout() {
            icon.auto = false
            content.add(icon)
            icon.box(in: content)
        }
    }
}
