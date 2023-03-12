import Foundation

class RootViewController: BaseTabBarController {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        self.defaultBarStyle()
        self.configItemStyle()
    }
    
    /// 设置每个Item内容
    func configItemStyle() {
        var viewControllers = [TabItem]()
        
        let listVC = TabItem(title: "列表", normalName: "vc_list", seletedName: "vc_list", viewController: BaseNavigationController(rootViewController: ListViewController()))
        viewControllers.append(listVC)
        
        let homeVC = TabItem(title: "我的", normalName: "vc_home", seletedName: "vc_home", viewController: BaseNavigationController(rootViewController: HomeViewController()))
        viewControllers.append(homeVC)
        
        addChildController(items: viewControllers)
    }
}
