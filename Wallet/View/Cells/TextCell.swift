import UIKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Text: Cell {
        public override class var identifier: String {
            return "textCell"
        }
        public override var list: List? {
            didSet {
                text.router = list?.controller
            }
        }
        private let text = InterfaceKit.Text()
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            text.clear()
        }
        
        public func configure(with text: Store.Item.Text) {
            switch text {
            case .head(let body):
                self.text.set(text: body, attributes: .attributes(for: .title(size: .large), color: .xFFFFFF, alignment: .center))
            case .lead(let body):
                self.text.set(text: body, attributes: .attributes(for: .text(size: .medium), color: .xFFFFFF, alignment: .left))
            case .body(let body):
                self.text.set(text: body, attributes: .attributes(for: .text(size: .small), color: .xFFFFFF, alignment: .left))
            case .quote(let body):
                self.text.set(text: body, attributes: .attributes(for: .text(size: .small), color: .x8B93A1, alignment: .left))
            case .center(let body):
                self.text.set(text: body, attributes: .attributes(for: .text(size: .medium), color: .x8B93A1, alignment: .center))
            }
        }
        
        public override func setup() {
            super.setup()
            layout()
        }
        
        private func layout() {
            text.clipsToBounds = true
            text.auto = false
            content.add(text)
            text.box(in: content, insets: .insets(top: 0, left: 16, right: 16, bottom: 0))
        }
    }
}
