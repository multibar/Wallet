import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Header {
    public class Coin: Header {
        public override class var identifier: String {
            return "coinHeader"
        }
        
        private let icon = Icon()
                
        public override func prepareForReuse() {
            super.prepareForReuse()
            icon.clear()
        }
        
        public func configure(with coin: CoreKit.Coin) {
            icon.color = .xEEEFEF
            icon.load(from: coin.icons?.small?.url)
        }
        
        public override func setup() {
            super.setup()
            icon.corner(radius: 16)
            layout()
        }
        
        private func layout() {
            icon.auto = false
            content.add(icon)
            icon.top(to: content.top)
            icon.centerX(to: content.centerX)
            icon.aspect(ratio: 56)
        }
    }
}
