# APSlidableTabPageController

## Description:
- A slidable tab page controller written in Swift
- Supports iOS (Portrait + Landscape) and tvOS
- Configurable:
  - index bar position (top or bottom)
  - index bar height
  - number of index bar elements per page
  - index bar element image or text
  - coloring

![slidabletabpagecontrollerdemo](https://cloud.githubusercontent.com/assets/653946/17933575/d8ad7318-6a14-11e6-9b0e-d5cae9ae719c.gif)

## Installation:
- Fetch with Carthage, e.g:
- 'github "apegroup/apegroup-slidabletabpagecontroller-ios"'

## Usage example iOS:
```swift
import APSlidableTabPageController_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let tabPageCtrl = APSlidableTabPageControllerFactory.make(pages: createPages(count: 7))
    tabPageCtrl.maxNumberOfIndexBarElementsPerScreen = 4.5
    tabPageCtrl.indexBarHeightConstraint.constant = 49
    tabPageCtrl.indexBarElementColor = .black
    tabPageCtrl.indexIndicatorView.backgroundColor = .red
    tabPageCtrl.indexBarElementHighlightedColor = tabPageCtrl.indexIndicatorView.backgroundColor!
    tabPageCtrl.delegate = self

    window = UIWindow()
    window?.rootViewController = tabPageCtrl
    window?.makeKeyAndVisible()
    return true
}

private func createPages(count: Int) -> [APSlidableTabPageControllerPage] {
    return (0..<count).map { i -> APSlidableTabPageControllerPage in
        let vc = UIViewController()
        vc.view.backgroundColor = randomColor()
        vc.title = "\(i)"

        let page: APSlidableTabPageControllerPage
        if i == 0 {
            let indexBarElement = APIndexBarElement.image(UIImage(named: "icon-star")!, UIImage(named: "iconplane")!)
            page = APSlidableTabPageControllerPage(indexBarElement: indexBarElement, contentViewController: vc)
        } else if i == 1 {
            let indexBarElement = APIndexBarElement.title("hello there")
            page = APSlidableTabPageControllerPage(indexBarElement: indexBarElement, contentViewController :vc)
        } else {
            page = APSlidableTabPageControllerPage(contentViewController: vc)        
        }

        return page
    }
}

private func randomColor() -> UIColor {
    return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
}
}

extension AppDelegate: APSlidableTabPageControllerDelegate {
    func slidableTabPageController(_ slidableTabPageController: APSlidableTabPageController, didNavigateFrom oldPage: Int, to newPage: Int) {
        print("Page changed from '\(oldPage)' to  \(newPage)")
    }
}

```

## Restrictions:
- Must be instantiated from a NIB

## Known Issues:

Feel free to contribute!
