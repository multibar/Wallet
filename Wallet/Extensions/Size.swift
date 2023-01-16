import Foundation

public enum Size {
    case tab
    
    public var item: CGFloat {
        switch self {
        case .tab:
            return 56
        }
    }
    public var inset: CGFloat {
        switch self {
        case .tab:
            return 16
        }
    }
}
