import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

extension Attributes {
    public static func attributes(for style: Typography.Style,
                                  color: UIColor? = nil,
                                  alignment: NSTextAlignment = .left,
                                  lineBreak: NSLineBreakMode? = nil,
                                  strikethrough: Bool = false,
                                  hyphens: Bool = false) -> Attributes {
        let font: UIFont
        var spacing: Typography.Spacing = .zero
        switch style {
        case .text(let size, let family):
            switch size {
            case .heavy:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 20, weight: .heavy)
                case.mono:
                    font = .mono(size: 20, weight: .heavy)
                }
            case .large:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 16, weight: .bold)
                case.mono:
                    font = .mono(size: 16, weight: .heavy)
                }
            case .medium:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 12, weight: .medium)
                case.mono:
                    font = .mono(size: 14, weight: .heavy)
                }
            case .regular:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 14, weight: .regular)
                case.mono:
                    font = .mono(size: 14, weight: .regular)
                }
            case .small:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 12, weight: .regular)
                case.mono:
                    font = .mono(size: 11, weight: .heavy)
                    spacing = .spacing(line: 0.0, char: -0.5)
                }
            }
        case .title(let size, let family):
            switch size {
            case .heavy:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 40, weight: .black)
                case.mono:
                    font = .mono(size: 40, weight: .heavy)
                }
            case .large:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 32, weight: .heavy)
                case.mono:
                    font = .mono(size: 32, weight: .heavy)
                }
            case .medium:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 24, weight: .black)
                case.mono:
                    font = .mono(size: 24, weight: .heavy)
                }
            case .regular:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 20, weight: .regular)
                case.mono:
                    font = .mono(size: 20, weight: .medium)
                }
            case .small:
                switch family {
                case .system:
                    font = .systemFont(ofSize: 16, weight: .regular)
                case.mono:
                    font = .mono(size: 16, weight: .regular)
                }
            }
        case .custom(let size, let weight, let _spacing, let family):
            switch family {
            case .system:
                font = .systemFont(ofSize: size, weight: weight.system)
            case .mono:
                font = .mono(size: size, weight: weight)
            }
            spacing = _spacing
        }
        return Attributes(typography: Attributes.Typography(font: font, alignment: alignment, lineBreakMode: lineBreak, strikethrough: strikethrough, hyphens: hyphens, spacing: spacing), color: color)
    }
}
extension Attributes.Typography {
    public enum Style {
        case text(size: Size, family: Family = .system)
        case title(size: Size, family: Family = .system)
        case custom(size: CGFloat, weight: Weight, spacing: Spacing = .zero, family: Family = .system)
    }
}
extension Attributes.Typography.Style {
    public enum Size {
        case heavy
        case large
        case medium
        case regular
        case small
    }
    public enum Weight {
        case heavy
        case bold
        case semibold
        case medium
        case regular
        case light
        
        fileprivate var system: UIFont.Weight {
            switch self {
            case .heavy   : return .heavy
            case .bold    : return .bold
            case .semibold: return .semibold
            case .medium  : return .medium
            case .regular : return .regular
            case .light   : return .light
            }
        }
        fileprivate var value: String {
            switch self {
            case .heavy   : return "Heavy"
            case .bold    : return "Bold"
            case .semibold: return "Semibold"
            case .medium  : return "Medium"
            case .regular : return "Regular"
            case .light   : return "Light"
            }
        }
    }
    public enum Family {
        case system
        case mono
    }
}

extension UIFont {
    fileprivate class func mono(size: CGFloat, weight: Attributes.Typography.Style.Weight) -> UIFont {
        return UIFont(name: "SFMono-\(weight.value)", size: size) ?? .systemFont(ofSize: size, weight: weight.system)
    }
}
extension String {
    public func width(with font: UIFont) -> CGFloat {
        return self.size(withAttributes: [.font: font]).width
    }
}
