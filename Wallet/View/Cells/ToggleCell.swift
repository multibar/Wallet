import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public struct Toggle {}
}

extension Cell.Toggle {
    public class Location: Cell {
        public override class var identifier: String {
            return "locationToggleCell"
        }
        private let local = Label()
        private let toggle = UISwitch()
        private let icloud = Label()
        
        private var location: Keychain.Location? {
            didSet {
                reset()
                processor?.location = location
            }
        }
        private weak var processor: RecoveryPhraseProcessor?

        public func configure(with location: Keychain.Location, processor: RecoveryPhraseProcessor) {
            self.location = location
            self.processor = processor
            self.toggle.setOn(location == .icloud, animated: false)
            self.reset()
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            toggle.interactive = false
            toggle.onTintColor = .x58ABF5
        }
        private func layout() {
            let helper = View()
            helper.add(gesture: .tap(target: self, action: #selector(toggled)))
            
            local.auto = false
            toggle.auto = false
            icloud.auto = false
            helper.auto = false
            
            content.add(local)
            content.add(toggle)
            content.add(icloud)
            content.add(helper)
            
            toggle.center(in: content, ratio: nil)
            
            local.top(to: toggle.top)
            local.right(to: toggle.left, constant: 16)
            local.bottom(to: toggle.bottom)
            
            icloud.top(to: toggle.top)
            icloud.left(to: toggle.right, constant: 16)
            icloud.bottom(to: toggle.bottom)
            
            helper.top(to: content.top)
            helper.left(to: local.left, constant: -16)
            helper.right(to: icloud.right, constant: -16)
            helper.bottom(to: content.bottom)
        }
        private func reset() {
            local.set(text: "Local",
                      attributes: .attributes(for: .text(size: .medium), color: location == .local ? .xFFFFFF : .x8B93A1, alignment: .right),
                      animated: true)
            icloud.set(text: "iCloud",
                       attributes: .attributes(for: .text(size: .medium), color: location == .icloud ? .xFFFFFF : .x8B93A1, alignment: .right),
                       animated: true)
        }
        
        @objc
        private func toggled() {
            Haptic.prepare()
            Haptic.impact(.medium).generate()
            toggle.setOn(!toggle.isOn, animated: true)
            location = toggle.isOn ? .icloud : .local
        }
    }
}
