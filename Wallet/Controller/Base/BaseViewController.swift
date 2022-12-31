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
    public var orders: OrderedSet<Store.Order> = []
    
    public let content = UIView()
    
    open var navBar: NavigationController.Bar? {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    open var navBarStyle: NavigationController.Bar.Style {
        return .none
    }
    open var navBarItems: [NavigationController.Bar.Item] {
        return []
    }
    open var navBarOffsets: Bool {
        return false
    }
    open var scroll: UIScrollView? {
        return nil
    }
    open var forcePresent: Bool {
        return false
    }
    open var containerA: Container? {
        return nil
    }
    open var containerB: Container? {
        return nil
    }
    open var multibar: Bool {
        return true
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    open override var shouldAutorotate: Bool {
        return true
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public required init(route: Route, query: Store.Query = .none, load: Bool = true) {
        self.route = route
        self.store = Store(route: route, query: query, load: load)
        super.init(nibName: nil, bundle: nil)
        log(event: "\(self.debugDescription) initialized")
        store.customer = self
        view.relayout()
        prepare()
    }
    public required init?(coder: NSCoder) {
        self.route = .none
        self.store = Store(route: .none)
        super.init(coder: coder)
        log(event: "\(self.debugDescription) initialized")
        store.customer = self
        view.relayout()
        prepare()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        log(event: "viewDidLoad: \(route.destination)", silent: true)
        setup()
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    open func setup() {
        setupUI()
        setupContent()
    }
    open func setupUI() {
        view.color = .x151A26
    }
    open func setupContent() {
        content.auto = false
        view.add(content)
        content.top(to: view.top)
        content.left(to: view.safeLeft)
        content.right(to: view.safeRight)
        content.bottom(to: view.bottom)
    }
    
    open func update(forced: Bool = false) {
        forced ? store.order(.reload) : store.updateIfNeeded()
    }
    
    open func app(state: System.App.State) {
        switch state {
        case .willEnterForeground:
            update()
        default:
            break
        }
    }
    open func user(state: System.User.State) {}
    open func update(trait collection: UITraitCollection) {}
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
        log(event: "\(self.debugDescription) deinitialized")
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
extension Route.Add.Stage {
    public var title: String {
        switch self {
        case .coins : return "Select Coin"
        case .coin  : return "Wallet"
        case .store : return "Store Wallet"
        case .create: return "Create Wallet"
        case .import: return "Import Wallet"
        }
    }
}