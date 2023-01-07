import UIKit
import CoreKit
import LayoutKit
import InterfaceKit

extension Cell {
    public struct Stepper {}
}

extension Cell.Stepper {
    public class Words: Cell {
        public override class var identifier: String {
            return "wordsStepperCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(left: 16, right: 16)
        }
        private let subtract = UIImageView(image: .operator_subtract)
        private let label = Label()
        private let add = UIImageView(image: .operator_add)
        private let impact = Haptic.Impactor(style: .medium)
        
        private var words: Int = 0 {
            didSet {
                label.set(text: "\(words) phrases", attributes: .attributes(for: .text(size: .medium), color: .xFFFFFF, alignment: .center))
            }
        }
        private weak var processor: RecoveryPhraseProcessor?
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            label.clear()
        }
        
        public func configure(with words: Int, processor: RecoveryPhraseProcessor) {
            self.processor = processor
            self.words = words
            self.impact.prepare()
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            subtract.interactive = true
            subtract.add(gesture: .tap(target: self, action: #selector(_subtract)))
            add.interactive = true
            add.add(gesture: .tap(target: self, action: #selector(_add)))
        }
        private func layout() {
            label.auto = false
            subtract.auto = false
            add.auto = false
            
            content.add(label)
            content.add(subtract)
            content.add(add)
            
            label.width(100)
            label.center(in: content)

            subtract.aspect(ratio: 32)
            subtract.centerY(to: label.centerY)
            subtract.right(to: label.left)
            
            add.aspect(ratio: 32)
            add.centerY(to: label.centerY)
            add.left(to: label.right)
        }
        
        @objc
        private func _subtract() {
            guard words > 12 else { return }
            impact.generate()
            words -= 1
            processor?.words = words
        }
        @objc
        private func _add() {
            guard words < 32 else { return }
            impact.generate()
            words += 1
            processor?.words = words
        }
    }
}
