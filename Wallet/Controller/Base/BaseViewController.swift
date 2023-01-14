import UIKit
import CoreKit
import NetworkKit
import InterfaceKit
import SafariServices
import OrderedCollections

open class BaseViewController: UIViewController, ViewController, Customer {
    public let identifier = UUID()
    public let route: Route
    public let store: Store
    
    public let content = UIView()
    
    open var navBar: NavigationController.Bar? { didSet { setNeedsStatusBarAppearanceUpdate() } }
    open var navBarStyle: NavigationController.Bar.Style { .navigation }
    open var navBarItems: [NavigationController.Bar.Item] { [] }
    open var navBarHidden: Bool { false }
    open var navBarOffsets: Bool { false }
    open var forcePresent: Bool { false }
    open var containerA: Container? { nil }
    open var containerB: Container? { nil }
    open var multibar: Bool { true }
    open var scroll: UIScrollView? { nil }
    open var background: UIColor { .x151A26 }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    open override var shouldAutorotate: Bool { true }
    open override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    open override var prefersStatusBarHidden: Bool { false }
    
    public init(route: Route, query: Store.Query = .none, load: Bool = true) {
        self.route = route
        self.store = Store(route: route, query: query)
        super.init(nibName: nil, bundle: nil)
        store.set(customer: self, load: load)
        relayout()
        prepare()
        log(event: "\(self.debugDescription) initialized, route: \(route.destination)", silent: true)
    }
    public required init?(coder: NSCoder) { nil }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        update(traits: traits)
    }
    open func setup() {
        setupUI()
        setupContent()
    }
    open func setupUI() {
        view.color = background
    }
    open func setupContent() {
        content.auto = false
        view.add(content)
        content.top(to: view.top)
        content.left(to: view.safeLeft)
        content.right(to: view.safeRight)
        content.bottom(to: view.bottom)
    }
    
    open func refresh(forced: Bool = false) {
        forced ? store.order(.reload) : store.updateIfNeeded()
    }
    
    open func app(state: System.App.State) {
        switch state {
        case .willEnterForeground:
            refresh()
        default:
            break
        }
    }
    open func user(state: System.User.State) {}
    open func update(traits: UITraitCollection) {}
    open func process(route: Route) {
        guard route != self.route else {
            rebuild()
            return
        }
        guard tabViewController?.viewControllers.contains(where: {$0.rootRoute == route}) == false else {
            tabViewController?.process(route: route)
            return
        }
        switch route.destination {
        case .add(let add):
            switch add {
            case .store(let store):
                switch store {
                case .recovery:
                    navigation?.push(InputViewController(route: route))
                default:
                    navigation?.push(ListViewController(route: route))
                }
            default:
                navigation?.push(ListViewController(route: route))
            }
        case .wallet:
            navigation?.push(WalletViewController(route: route))
        case .unknown(let unknown):
            guard let url = unknown.url?.absoluteString.url else { break }
            safari(with: url)
        default:
            navigation?.push(ListViewController(route: route))
        }
    }
    open func prepare() {}
    open func rebuild() {}
    open func destroy() {}
    open func receive(order: Store.Order, from store: Store) async {}
    
    deinit {
        log(event: "\(self.debugDescription) deinitialized, route: \(route.destination)", silent: true)
    }
}
extension BaseViewController {
    public func safari(with url: URL) {
        let url = url.valid ? url : url.string.url
        guard let url else { return }
        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .done
        safari.preferredBarTintColor = .x151A26
        safari.preferredControlTintColor = .x58ABF5
        safari.modalPresentationCapturesStatusBarAppearance = true
        safari.modalPresentationStyle = .pageSheet
        present(safari, animated: true, completion: nil)
    }
}
extension Route.Add {
    public var title: String {
        switch self {
        case .coins:
            return "Choose Coin"
        case .coin:
            return "Wallet"
        case .store(let store):
            switch store {
            case .location:
                return "Location"
            case .recovery:
                return "Recovery Phrase"
            }
        case .create:
            return "Create Wallet"
        case .import:
            return "Import Wallet"
        }
    }
}
