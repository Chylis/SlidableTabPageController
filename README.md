# SlidableTabPageController

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
- 'github "chylis/SlidableTabPageController"'

## Usage example iOS:
```swift
import SlidableTabPageController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let tabPageCtrl = SlidableTabPageControllerFactory.make(pages: createPages(count: 7))
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

  private func createPages(count: Int) -> [SlidableTabPageControllerPage] {
    return (0..<count).map { i -> SlidableTabPageControllerPage in
      let vc = UIViewController()
        vc.view.backgroundColor = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
        vc.title = "\(i)"

        let page: SlidableTabPageControllerPage
        if i == 0 {
          let indexBarElement = IndexBarElement.image(UIImage(named: "icon-star")!, UIImage(named: "iconplane")!)
            page = SlidableTabPageControllerPage(indexBarElement: indexBarElement, contentViewController: vc)
        } else if i == 1 {
          let indexBarElement = IndexBarElement.title("hello there")
            page = SlidableTabPageControllerPage(indexBarElement: indexBarElement, contentViewController :vc)
        } else {
          page = SlidableTabPageControllerPage(contentViewController: vc)        
        }

      return page
    }
  }
}

extension AppDelegate: SlidableTabPageControllerDelegate {
  func slidableTabPageController(_ slidableTabPageController: SlidableTabPageController, didNavigateFrom oldPage: Int, to newPage: Int) {
    print("Page changed from '\(oldPage)' to  \(newPage)")
  }
}

```

## Restrictions:

## Known Issues:

Feel free to contribute!
