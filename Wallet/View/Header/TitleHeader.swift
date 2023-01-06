import UIKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Header {
    public class Title: Header {
        public override class var identifier: String {
            return "titleHeader"
        }
        
        private let title = Label(lines: 0)
                
        public override func prepareForReuse() {
            super.prepareForReuse()
            title.clear()
        }
        
        public func configure(with text: String, size: Size) {
            self.title.set(text: text, attributes: .attributes(for: .title(size: size.attributed), color: .xFFFFFF))
        }
        
        public override func setup() {
            super.setup()
            layout()
        }
        
        private func layout() {
            title.auto = false
            content.add(title)
            title.box(in: content, insets: .insets(left: 16, right: 16))
        }
    }
}
extension Header.Title {
    public enum Size {
        case large
        case medium
        case small
        
        public var attributed: Attributes.Typography.Style.Size {
            switch self {
            case .large:
                return .large
            case .medium:
                return .medium
            case .small:
                return .small
            }
        }
    }
}
extension Store.Section.Header.Title {
    public var size: Header.Title.Size {
        switch self {
        case .large:
            return .large
        case .medium:
            return .medium
        case .small:
            return .small
        }
    }
}
