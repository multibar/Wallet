import UIKit
import LayoutKit
import InterfaceKit

extension Cell {
    public class Loader: Cell {
        public override class var identifier: String {
            return "loaderCell"
        }
        
        private let loader = Activity()
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            loader.set(loading: false)
        }
        
        public func set(loading: Bool) {
            loader.set(loading: loading)
        }
        
        public override func setup() {
            super.setup()
            layout()
        }
        
        private func layout() {
            loader.auto = false
            content.add(loader)
            loader.top(to: content.top)
            loader.bottom(to: content.bottom)
            loader.centerX(to: content.centerX)
        }
    }
}

fileprivate typealias Activity = Loader
