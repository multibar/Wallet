import UIKit
import CoreKit
import LayoutKit
import InterfaceKit

extension Cell {
    public class Wallet: Cell {
        public override class var identifier: String {
            return "walletCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(top: 0, left: 16, right: 16, bottom: 0)
        }
        
        private let title = Label()
        private let location = UIImageView()
        private let chevron = UIImageView(image: .chevron_right)
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            title.clear()
            location.clear()
        }
        
        public func configure(with wallet: CoreKit.Wallet) {
            title.set(text: wallet.title, attributes: .attributes(for: .text(size: .large), color: .xFFFFFF, lineBreak: .byTruncatingMiddle))
            location.image = wallet.location.icon
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            content.corner(radius: 16)
            content.color = .xFFFFFF_05
        }
        private func layout() {
            title.auto = false
            location.auto = false
            chevron.auto = false
            
            content.add(title)
            content.add(location)
            content.add(chevron)
            
            title.top(to: content.top)
            title.left(to: content.left, constant: 16)
            title.bottom(to: content.bottom)
            
            location.aspect(ratio: 24)
            location.left(to: title.right, constant: 8)
            location.centerY(to: content.centerY)
            
            chevron.aspect(ratio: 32)
            chevron.left(to: location.right, constant: 8)
            chevron.right(to: content.right, constant: 16)
            chevron.centerY(to: location.centerY)
        }
    }
}
