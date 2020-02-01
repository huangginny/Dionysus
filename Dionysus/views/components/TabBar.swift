//
//  https://stackoverflow.com/a/58164937
//

import SwiftUI
import UIKit

struct TabBar: View {
    var viewControllers: [UIHostingController<AnyView>]
    @State var selection = 0

    init(_ tabs: [Tab]) {
        self.viewControllers = tabs.map {
            let host = UIHostingController(rootView: $0.view)
            host.tabBarItem = $0.barItem
            return host
        }
    }

    var body: some View {
        TabBarController(controllers: viewControllers, selection: $selection)
            .edgesIgnoringSafeArea(selection == 0 ? .vertical : .bottom)
    }

    struct Tab {
        var view: AnyView
        var barItem: UITabBarItem

        init<V: View>(view: V, barItem: UITabBarItem) {
            self.view = AnyView(view)
            self.barItem = barItem
        }
    }
}

struct TabBarController: UIViewControllerRepresentable {
    
    var controllers: [UIViewController]
    @Binding var selection: Int

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarControllerWithDelegate()
        tabBarController.delegate = tabBarController
        tabBarController.updateSelectedIndex = { self.selection = $0 }
        tabBarController.viewControllers = controllers
        tabBarController.selectedIndex = selection
        return tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UITabBarController, context: UIViewControllerRepresentableContext<TabBarController>) {
        uiViewController.selectedIndex = selection
        return
    }
}

class UITabBarControllerWithDelegate: UITabBarController, UITabBarControllerDelegate {
    var updateSelectedIndex: ((Int) -> Void)?
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        if let f = updateSelectedIndex {
            f(tabBarController.selectedIndex)
        }
    }
}
