import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

public protocol RecoveryPhraseProcessor: AnyObject {
    func scroll(to input: UIView)
    func process(phrases: [String], for coin: Coin, at location: Wallet.Location)
}

extension Cell {
    public class Recovery: Cell, RecoveryPhraseInputDelegate {
        public override class var identifier: String {
            return "recoveryCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(top: 0, left: 32, right: 32, bottom: 0)
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
        private var inputs: [Phrase] = []
        private let button = Label()
        
        private var coin: CoreKit.Coin?
        private var location: CoreKit.Wallet.Location?
        private weak var processor: RecoveryPhraseProcessor?
        
        public func configure(with coin: CoreKit.Coin, location: CoreKit.Wallet.Location, processor: RecoveryPhraseProcessor) {
            guard inputs.empty else { return }
            self.coin = coin
            self.location = location
            self.processor = processor
            self.button.set(text: "DONE", attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
            for i in 1...coin.words/2 {
                let input = Phrase(number: i, last: false, delegate: self)
                inputs.append(input)
                LStack.append(input)
            }
            for i in (coin.words/2 + 1)...coin.words {
                let input = Phrase(number: i, last: i == coin.words, delegate: self)
                inputs.append(input)
                RStack.append(input)
            }
            typed()
        }
        
        public override func setup() {
            super.setup()
            button.color = .x58ABF5
            button.corner(radius: 8)
            button.add(gesture: .tap(target: self, action: #selector(done)))
            layout()
        }
        private func layout() {
            LStack.auto = false
            RStack.auto = false
            button.auto = false

            content.add(LStack)
            content.add(RStack)
            content.add(button)
            
            LStack.top(to: content.top)
            LStack.left(to: content.left)
            LStack.right(to: content.centerX, constant: 12)
            LStack.bottom(to: button.top, constant: 40)
            
            RStack.top(to: content.top)
            RStack.left(to: content.centerX, constant: 12)
            RStack.right(to: content.right)
            RStack.bottom(to: button.top, constant: 40)
            
            LStack.height(to: RStack.height)
                        
            button.height(56)
            button.left(to: content.left)
            button.right(to: content.right)
            button.bottom(to: content.bottom)
        }
        fileprivate func intercepted(input view: UIView) {
            processor?.scroll(to: view)
        }
        fileprivate func typed() {
            let active: Bool = {
                guard let coin else { return false }
                return inputs.compactMap({$0.phrase}).count == coin.words
            }()
            button.alpha = active ? 1.0 : 0.33
            button.color = active ? .x58ABF5 : .xFFFFFF_05
            button.interactive = active
        }
        fileprivate func next() {
            guard let coin else { return }
            guard let typing = inputs.first(where: {$0.typing}) else {
                inputs.first?.intercept()
                return
            }
            guard typing != inputs.last, typing.number != coin.words else {
                done()
                return
            }
            inputs[typing.number].intercept()
        }
        @objc
        fileprivate func done() {
            let phrases = inputs.compactMap({$0.phrase})
            guard let coin, let location, phrases.count == coin.words else {
                inputs.forEach({$0.failure()})
                return
            }
            button.interactive = false
            inputs.forEach({$0.interactive = false; $0.success()})
            button.clear()
            let loader = Activity()
            loader.set(loading: true)
            loader.auto = false
            button.add(loader)
            loader.center(in: button, ratio: 48)
            processor?.process(phrases: phrases, for: coin, at: location)
        }
    }
}
fileprivate protocol RecoveryPhraseInputDelegate: AnyObject {
    func intercepted(input view: UIView)
    func typed()
    func next()
    func done()
}
extension Cell.Recovery {
    private class Phrase: View, UITextFieldDelegate {
        public let number: Int
        private let last: Bool
        private let text = Label()
        private let input = UITextField()
        private let underscore = View()
                
        private weak var delegate: RecoveryPhraseInputDelegate?
        
        public var typing: Bool { input.isFirstResponder }
        public var phrase: String? {
            guard let phrase = input.text,
                  !phrase.empty,
                  !phrase.replacingOccurrences(of: " ", with: "").empty
            else { return nil }
            return phrase
        }
        
        public func intercept() {
            input.becomeFirstResponder()
        }
        public func success() {
            input.resignFirstResponder()
            View.animate(duration: 0.33) {
                self.underscore.color = .x5CC489
            }
        }
        public func failure() {
            input.resignFirstResponder()
            guard phrase == nil else { return }
            View.animate(duration: 0.33) {
                self.underscore.color = .xF36655
            }
        }
        public func reset() {
            View.animate(duration: 0.33) {
                self.underscore.color = .x8B93A1_20
            }
        }
        public required init(number: Int, last: Bool, delegate: RecoveryPhraseInputDelegate) {
            self.number = number
            self.last = last
            self.delegate = delegate
            super.init(frame: .zero)
            self.text.set(text: "\(number).", attributes: .attributes(for: .text(size: .small, family: .mono), color: .x8B93A1, alignment: .left))
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            input.delegate = self
            input.font = Attributes.attributes(for: .text(size: .medium, family: .mono)).typography.font
            input.color = .clear
            input.textColor = .xFFFFFF
            input.tintColor = .x58ABF5
            input.borderStyle = .none
            input.keyboardType = .default
            input.clearButtonMode = .never
            input.enablesReturnKeyAutomatically = true
            input.returnKeyType = last ? .done : .next
            input.addTarget(self, action: #selector(typed), for: .editingChanged)
            underscore.color = .x8B93A1_20
        }
        private func layout() {
            text.auto = false
            input.auto = false
            underscore.auto = false
            
            add(text)
            add(input)
            add(underscore)
            
            height(32)
            
            text.left(to: left)
            text.base(line: .last, to: input.line(.last))
            text.width(24)
            
            input.top(to: top, constant: 2)
            input.left(to: text.right, constant: 2)
            input.right(to: right, constant: 2)
            input.bottom(to: bottom, constant: 2)
            
            underscore.height(1)
            underscore.left(to: input.left)
            underscore.right(to: input.right)
            underscore.bottom(to: input.line(.last), constant: -6)
        }
        
        @objc
        private func typed() {
            delegate?.typed()
        }
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return string != " "
        }
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            last ? delegate?.done() : delegate?.next()
            if last { input.resignFirstResponder() }
            return true
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            guard phrase == nil else { return }
            failure()
        }
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            delegate?.intercepted(input: self)
            return true
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
            reset()
        }
    }
}
fileprivate typealias Activity = Loader
