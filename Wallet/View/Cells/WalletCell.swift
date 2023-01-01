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
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            
        }
        
        public func configure(with wallet: CoreKit.Wallet) {
            
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
            
        }
    }
}
