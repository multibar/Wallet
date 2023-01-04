import UIKit
import CoreKit
import InterfaceKit

public protocol KeyboardHandler: AnyObject {
    var keyboard: CGFloat { get }
}
public protocol KeyboardDelegate: AnyObject {
    func pressed(key: Keyboard.Key)
}

public struct Keyboard {}
extension Keyboard {
    public class Numeric: View {
        private let vertical: Stack = {
            let stack = Stack()
            stack.axis = .vertical
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 8
            return stack
        }()
        
        public weak var delegate: KeyboardDelegate?
        
        public override func setup() {
            super.setup()
            setupKeys()
        }
        private func setupKeys() {
            
        }
    }
}
extension Keyboard {
    public class Key: View.Interactive {
        public let value: Value
        private let icon = UIImageView()
        private let label = Label()
        
        public required init(value: Value) {
            self.value = value
            super.init(frame: .zero)
        }
        public required init?(coder: NSCoder) { nil }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            switch value {
            case .number(let number):
                label.set(text: "\(number)", attributes: .attributes(for: .text(size: .heavy)))
            case .character(let character):
                label.set(text: "\(character)", attributes: .attributes(for: .text(size: .heavy)))
            case .delete:
                icon.image = .keyboard_delete
            case .biometry:
                switch System.Device.biometry {
                case .faceID:
                    icon.image = .biometry_faceID
                case .touchID:
                    icon.image = .biometry_touchID
                default:
                    icon.image = nil
                }
            }
        }
        private func layout() {
            
        }
    }
}
extension Keyboard.Key {
    public enum Value {
        case number(Int)
        case character(Character)
        case delete
        case biometry
    }
}
