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
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            title.clear()
        }
        
        public func configure(with wallet: CoreKit.Wallet) {
            title.set(text: wallet.title, attributes: .attributes(for: .title(size: .medium), color: .xFFFFFF, lineBreak: .byTruncatingMiddle))
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
            content.add(title)
            title.base(line: .first, to: content.top, constant: 32)
            title.left(to: content.left, constant: 16)
            title.right(to: content.right, constant: 16)
        }
    }
}
