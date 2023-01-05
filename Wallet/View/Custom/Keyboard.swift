import UIKit
import CoreKit
import InterfaceKit

public protocol KeyboardHandler: AnyObject {
    var keyboard: CGFloat { get }
}
public protocol KeyboardDelegate: AnyObject {
    func pressed(key: Keyboard.Key)
}

public class Keyboard: View {
    private var keys: [Key] = []
    public weak var delegate: KeyboardDelegate?
    public func pressed(key: Key) {
        delegate?.pressed(key: key)
    }
}
extension Keyboard {
    public class Numeric: Keyboard {
        private let vertical: Stack = {
            let vertical = Stack()
            vertical.axis = .vertical
            vertical.alignment = .fill
            vertical.distribution = .fill
            vertical.spacing = 8
            return vertical
        }()
        private var horizontal: Stack {
            let horizontal = Stack()
            horizontal.axis = .horizontal
            horizontal.alignment = .fill
            horizontal.distribution = .fill
            horizontal.spacing = 8
            return horizontal
        }
        
        public override func setup() {
            super.setup()
            setupKeys()
            layout()
        }
        private func setupKeys() {
            let ratio: CGFloat = 80
            var first: [Key] = []
            var second: [Key] = []
            var third: [Key] = []
            var fourth: [Key] = []
            
            for number in 1...3 {
                first.append(Key(value: .number(number), ratio: ratio))
            }
            for number in 4...6 {
                second.append(Key(value: .number(number), ratio: ratio))
            }
            for number in 7...9 {
                third.append(Key(value: .number(number), ratio: ratio))
            }
            
            fourth.append(Key(value: .biometry, ratio: ratio))
            fourth.append(Key(value: .number(0), ratio: ratio))
            fourth.append(Key(value: .delete, ratio: ratio))
            
            [first, second, third, fourth].forEach { row in
                let horizontal = horizontal
                horizontal.height(ratio)
                
                let left = View()
                let centerL = View()
                let centerR = View()
                let right = View()
                
                horizontal.append(left)
                row.enumerated().forEach { number, key in
                    switch number {
                    case 1:
                        horizontal.append(centerL)
                        horizontal.append(key)
                        horizontal.append(centerR)
                    default:
                        horizontal.append(key)
                    }
                    keys.append(key)
                }
                horizontal.append(right)
                [centerL, centerR, right].forEach({$0.width(to: left.width)})
                
                vertical.append(horizontal)
            }
        }
        private func layout() {
            vertical.auto = false
            add(vertical)
            vertical.box(in: self)
        }
    }
}
extension Keyboard {
    public class Key: View.Interactive {
        public let value: Value
        public let ratio: CGFloat
        private let icon = UIImageView()
        private let label = Label()
        
        public override var highlighted: Bool {
            didSet { set(highlighted: highlighted) }
        }
        
        public override var touches: View.Interactive.Touches {
            didSet {
                Haptic.prepare()
                switch touches {
                case .finished(let success):
                    guard success else { return }
                    Haptic.selection.generate()
                    keyboard?.pressed(key: self)
                default:
                    break
                }
            }
        }
        public weak var keyboard: Keyboard?
        
        public func set(highlighted: Bool, animated: Bool = true) {
            View.animate(duration: 0.33, spring: 1.0, velocity: 1.0) {
                switch self.value {
                case .biometry:
                    self.transform = highlighted ? .scale(to: 0.8) : .identity
                default:
                    self.color = highlighted ? .xFFFFFF_05 : .clear
                }
            }
        }
        public required init(value: Value, ratio: CGFloat) {
            self.value = value
            self.ratio = ratio
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
                corner(radius: ratio/2, curve: .circular)
                label.set(text: "\(number)", attributes: .attributes(for: .title(size: .large), color: .xFFFFFF, alignment: .center))
            case .character(let character):
                corner(radius: ratio/2, curve: .circular)
                label.set(text: "\(character)", attributes: .attributes(for: .title(size: .large), color: .xFFFFFF, alignment: .center))
            case .delete:
                corner(radius: ratio/2, curve: .circular)
                icon.image = .keyboard_delete
            case .biometry:
                corner(radius: 0)
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
            auto = false
            let inset = ratio/4
            switch value {
            case .delete, .biometry:
                icon.auto = false
                add(icon)
                icon.box(in: self, insets: .insets(top: inset, left: inset, right: inset, bottom: inset))
            case .number, .character:
                label.auto = false
                add(label)
                label.box(in: self, insets: .insets(top: inset, left: inset, right: inset, bottom: inset))
            }
            aspect(ratio: ratio)
        }
    }
}
extension Keyboard.Key {
    public enum Value: Hashable, Equatable {
        case number(Int)
        case character(Character)
        case delete
        case biometry
    }
}
