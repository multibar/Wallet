import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Option: Cell {
        public override class var identifier: String {
            return "optionCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(top: 0, left: 16, right: 16, bottom: 0)
        }
        
        private let icon = UIImageView()
        private let title = Label()
        private let subtitle = Label()
        private let chevron = UIImageView(image: .chevron_right)
        private let toggle = UISwitch()
        private let separator = View()

        private var option: Store.Item.Option?
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            option = nil
            icon.clear()
            title.clear()
            subtitle.clear()
            chevron.alpha = 0.0
            toggle.alpha = 0.0
            separator.alpha = 0.0
        }

        public func action() {
            switch option {
            case .currency:
                Haptic.prepare()
                Haptic.impact(.medium).generate()
                switch Settings.Network.Fiat.preferred {
                case "USD":
                    Settings.Network.Fiat.preferred = "EUR"
                    icon.image = .option_EUR
                    subtitle.set(text: "EUR", attributes: .attributes(for: .title(size: .small), color: .x8B93A1, alignment: .right), animated: true)
                case "EUR":
                    Settings.Network.Fiat.preferred = "USD"
                    icon.image = .option_USD
                    subtitle.set(text: "USD", attributes: .attributes(for: .title(size: .small), color: .x8B93A1, alignment: .right), animated: true)
                default:
                    break
                }
            case .passcode:
                (list?.controller as? Multibar)?.controller?.passcode(action: .change)
            case .biometry:
                toggled()
            default:
                break
            }
        }
        public func configure(with option: Store.Item.Option, position: Position) {
            self.option = option
            var icon: UIImage?
            var title: String?
            var subtitle: String?
            var chevron = false
            var toggle = false
            var togglable = false
            switch option {
            case .currency:
                switch Settings.Network.Fiat.preferred {
                case "USD":
                    icon = .option_USD
                    subtitle = "USD"
                case "EUR":
                    icon = .option_EUR
                    subtitle = "USD"
                default:
                    break
                }
                title = "Currency"
                chevron = true
            case .passcode:
                icon = .option_reset
                title = "Reset passcode"
                chevron = true
            case .biometry:
                switch System.Device.biometry {
                case .faceID:
                    icon = .option_faceID
                    title = "Face ID"
                case .touchID:
                    icon = .option_touchID
                    title = "Touch ID"
                default:
                    break
                }
                toggle = Settings.App.biometry
                togglable = true
            }
            self.icon.image = icon
            self.title.set(text: title, attributes: .attributes(for: .text(size: .large), color: .xFFFFFF))
            self.subtitle.set(text: subtitle, attributes: .attributes(for: .title(size: .small), color: .x8B93A1, alignment: .right))
            self.chevron.alpha = chevron ? 1.0 : 0.0
            self.toggle.isOn = toggle
            self.toggle.alpha = togglable ? 1.0 : 0.0
            switch position {
            case .single:
                self.content.corners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .first:
                self.content.corners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .middle:
                self.content.corners = []
            case .last:
                self.content.corners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            self.separator.alpha = position == .last ? 0.0 : 1.0
        }
        public override func set(highlighted: Bool, animated: Bool = true) {
            View.animate(duration: 0.5,
                         spring: 1.0,
                         velocity: 1.0) {
                self.content.color = highlighted ? .xFFFFFF_20 : .xFFFFFF_05
            }
        }
        
        public override func setup() {
            super.setup()
            content.color = .xFFFFFF_05
            content.corner(radius: 16)
            separator.color = .x8B93A1_05
            separator.corner(radius: 0.5, curve: .circular)
            separator.corners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            toggle.interactive = false
            toggle.onTintColor = .x58ABF5
            layout()
        }
        private func layout() {
            icon.auto = false
            title.auto = false
            subtitle.auto = false
            chevron.auto = false
            toggle.auto = false
            separator.auto = false
            
            content.add(icon)
            content.add(title)
            content.add(subtitle)
            content.add(chevron)
            content.add(toggle)
            content.add(separator)
            
            icon.aspect(ratio: 32)
            icon.left(to: content.left, constant: 16)
            icon.centerY(to: content.centerY)
            
            title.left(to: icon.right, constant: 16)
            title.right(to: subtitle.left, constant: 8)
            title.centerY(to: content.centerY)
            
            subtitle.right(to: chevron.left, constant: 16)
            subtitle.centerY(to: content.centerY)
            
            chevron.aspect(ratio: 32)
            chevron.right(to: content.right, constant: 16)
            chevron.centerY(to: content.centerY)
            
            toggle.right(to: content.right, constant: 16)
            toggle.centerY(to: content.centerY)
            
            separator.height(1)
            separator.left(to: title.left)
            separator.right(to: content.right)
            separator.bottom(to: content.bottom)
        }
        
        private func toggled() {
            Haptic.prepare()
            Haptic.impact(.medium).generate()
            switch option {
            case .biometry:
                guard !Settings.App.biometry else {
                    Settings.App.biometry = false
                    toggle.setOn(false, animated: true)
                    break
                }
                Task {
                    do {
                        toggle.setOn(true, animated: true)
                        try await System.Device.authenticate(reason: "Enable biometry")
                        Settings.App.biometry = true
                    } catch {
                        Settings.App.biometry = false
                        toggle.setOn(false, animated: true)
                    }
                }
            default:
                break
            }
        }
    }
}
extension Cell.Option {
    public enum Position {
        case single
        case first
        case middle
        case last
    }
}
