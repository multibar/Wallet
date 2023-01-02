import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Phrase: Cell {
        public override class var identifier: String {
            return "phraseCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(top: 0, left: 32, right: 32, bottom: 0)
        }
        private var number = 0
        private var last = false
        private let label = Label()
        private let input = UITextField()
        private weak var processor: RecoveryPhraseProcessor?
        
        public var phrase: String? {
            guard let phrase = input.text,
                  !phrase.empty,
                  !phrase.replacingOccurrences(of: " ", with: "").empty
            else { return nil }
            return phrase.replacingOccurrences(of: " ", with: "")
        }
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            number = 0
            last = false
            label.clear()
            input.clear()
        }
        public func configure(with number: Int, last: Bool, phrase: String?, processor: RecoveryPhraseProcessor) {
            self.number = number
            self.last = last
            self.input.text = phrase
            self.processor = processor
            self.label.set(text: "\(number).", attributes: .attributes(for: .text(size: .medium, family: .mono), color: .x8B93A1, alignment: .left))
            self.input.returnKeyType = last ? .done : .next
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            content.corner(radius: 8)
            content.border(width: 1)
            content.border(color: .x8B93A1_20)
            
            input.delegate = self
            input.font = Attributes.attributes(for: .text(size: .large, family: .mono)).typography.font
            input.color = .clear
            input.textColor = .xFFFFFF
            input.tintColor = .x58ABF5
            input.borderStyle = .none
            input.keyboardType = .default
            input.keyboardAppearance = .dark
            input.clearButtonMode = .never
            input.enablesReturnKeyAutomatically = true
            input.returnKeyType = last ? .done : .next
            input.addTarget(self, action: #selector(typed), for: .editingChanged)
        }
        private func layout() {
            label.auto = false
            input.auto = false

            content.add(label)
            content.add(input)

            label.left(to: content.left, constant: 16)
            label.base(line: .last, to: input.line(.last))
            label.width(32)

            input.top(to: content.top)
            input.left(to: label.right)
            input.right(to: content.right)
            input.bottom(to: content.bottom)
        }
    }
}
extension Cell.Phrase: UITextFieldDelegate {
    public func begin() {
        input.becomeFirstResponder()
    }
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        processor?.scroll(to: number)
        return true
    }
    @objc
    private func typed() {
        processor?.phrases[number] = phrase
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !string.contains(" ")
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if last { input.resignFirstResponder() } else { processor?.inputs[number + 1]?.begin() }
        return true
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let phrase = phrase
        textField.text = phrase
        processor?.phrases[number] = phrase
    }
}