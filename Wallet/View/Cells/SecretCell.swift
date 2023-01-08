import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public struct Secret {}
}
extension Cell.Secret {
    public class Encrypted: Cell {
        public override class var identifier: String {
            return "encryptedSecretCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(left: 16, right: 16)
        }
        private let icon = UIImageView(image: .icon_locked)
        private let label = Label(lines: 0)
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            label.clear()
        }
        public func configure(with phrase: String) {
            label.set(text: phrase, attributes: .attributes(for: .text(size: .large, family: .mono), color: .x8B93A1, alignment: .center))
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            content.color = .xFFFFFF_05
            content.corner(radius: 16)
        }
        private func layout() {
            icon.auto = false
            label.auto = false
            
            content.add(icon)
            content.add(label)
            
            icon.aspect(ratio: 24)
            icon.top(to: content.top, constant: 8)
            icon.right(to: content.right, constant: 8)
            
            label.box(in: content, inset: 32)
        }
    }
}
extension Cell.Secret {
    public class Decrypted: Cell {
        public override class var identifier: String {
            return "decryptedSecretCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(left: 16, right: 16)
        }
        private let LStack: Stack = {
            let stack = Stack()
            stack.axis = .vertical
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 2
            return stack
        }()
        private let RStack: Stack = {
            let stack = Stack()
            stack.axis = .vertical
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 2
            return stack
        }()
        private let odd = Phrase(no: 0, word: "")
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            LStack.clear()
            RStack.clear()
            odd.alpha = 0.0
        }
        
        public func configure(with phrases: [String]) {
            var phrases = phrases
            let odd: Phrase? = phrases.count % 2 == 0 ? nil : Phrase(no: phrases.count, word: phrases.removeLast())
            phrases.chunked(into: phrases.count / 2).first?.enumerated().forEach { no, word in
                LStack.append(Phrase(no: no + 1, word: word))
            }
            phrases.chunked(into: phrases.count / 2).last?.enumerated().forEach { no, word in
                RStack.append(Phrase(no: no + (phrases.count / 2) + 1, word: word))
            }
            guard let odd else {
                self.odd.alpha = 0.0
                return
            }
            self.odd.alpha = 1.0
            self.odd.set(no: odd.no, word: odd.word)
        }
        
        public override func setup() {
            super.setup()
            layout()
        }
        private func layout() {
            LStack.auto = false
            RStack.auto = false
            odd.auto = false

            content.add(LStack)
            content.add(RStack)
            content.add(odd)

            LStack.top(to: content.top)
            LStack.left(to: content.left, rule: .more)
            LStack.right(to: content.centerX, constant: 8)
            LStack.bottom(to: odd.top)

            RStack.top(to: content.top)
            RStack.left(to: content.centerX, constant: 8)
            RStack.right(to: content.right, rule: .less)
            RStack.bottom(to: odd.top)

            LStack.height(to: RStack.height)
            
            odd.left(to: content.left, rule: .more)
            odd.right(to: content.right, rule: .less)
            odd.centerX(to: content.centerX)
            odd.bottom(to: content.bottom)
        }
    }
}

extension Cell.Secret.Decrypted {
    private class Phrase: View {
        public private(set) var no: Int
        public private(set) var word: String
        private let number = Label()
        private let phrase = Label()

        public required init(no: Int, word: String) {
            self.no = no
            self.word = word
            super.init(frame: .zero)
            set(no: no, word: word)
        }
        required init?(coder: NSCoder) { nil }
        
        public func set(no: Int, word: String) {
            self.no = no
            self.word = word
            self.number.set(text: "\(no).", attributes: .attributes(for: .text(size: .small, family: .mono), color: .x8B93A1))
            self.phrase.set(text: word, attributes: .attributes(for: .text(size: .large, family: .mono), color: .xFFFFFF, lineBreak: .byTruncatingMiddle))
        }

        public override func setup() {
            super.setup()
            layout()
        }
        private func layout() {
            number.auto = false
            phrase.auto = false

            add(number)
            add(phrase)

            height(32)

            number.left(to: left)
            number.base(line: .last, to: phrase.line(.last))
            number.width(24)

            phrase.left(to: number.right)
            phrase.right(to: right, constant: 2)
            phrase.base(line: .last, to: number.line(.last))
        }
    }
}
