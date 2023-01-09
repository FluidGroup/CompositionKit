
import StorybookKit
import UIKit

@MainActor
extension Book {
  
  static var dynamicAnimator: BookView {
    
    BookNavigationLink(title: "DynamicAnimator") {
      BookPush(title: "Push") {
        MyViewController()
      }
    }
    
  }
  
}

private final class MyViewController : UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
        
    let confettiView = EmitterView()
    confettiView.backgroundColor = .black
    confettiView.frame = view.bounds
    view.addSubview(confettiView)
    
    let button = UIButton(type: .system)
    button.setTitle("Emit", for: .normal)
    button.onTap {
      confettiView.emit(with: [
        .text("😀", 80),
        .text("❤️", 80),
        .text("🥑", 80),
        .text("💩", 80),
      ].randomElement()!)
    }
    
    button.frame = .init(origin: view.center, size: .init(width: 100, height: 40))
    
    button.setTitle("Send", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.center = view.center
    
    view.addSubview(button)
    
    self.view = view
  }
}

final class EmitterView: UIView {
  
  enum Content {
    case image(UIImage)
    case text(String, Double)
  }
  
  private lazy var animator = UIDynamicAnimator(referenceView: self)
  private let gravityBehavior = UIGravityBehavior(items: [])
  private let collisionBehavior = UICollisionBehavior(items: [])
  
  init() {
    super.init(frame: .zero)
    isUserInteractionEnabled = false
    gravityBehavior.gravityDirection = .init(dx: 0, dy: -1)
    
    //    let dynamicItemBehavior = UIDynamicItemBehavior(items: [])
    //    dynamicItemBehavior.friction = 0
    //    dynamicItemBehavior.elasticity = 0
    //    animator.addBehavior(dynamicItemBehavior)
    
    animator.addBehavior(gravityBehavior)
    animator.addBehavior(collisionBehavior)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func emit(with content: Content) {
    
    //    collisionBehavior.addBoundary(
    //      withIdentifier: "right-wall" as NSCopying,
    //      for: .init(
    //        rect: CGRect(
    //          origin: CGPoint(x: UIScreen.main.bounds.width-1, y: 0),
    //          size: CGSize(width: 1, height: UIScreen.main.bounds.height))
    //      )
    //    )
    
    (0...150).forEach { count in
      
      DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...1)) {
        
        let imageView = UIImageView(image: content.image)
        imageView.center = .init(
          x: Double.random(in: (self.bounds.width * 0.3)...(self.bounds.width * 0.7)),
          y: self.bounds.height + 40
        )
        
        let size = Double.random(in: 40...80)
        imageView.frame.size = .init(width: size, height: size)
        
        self.addSubview(imageView)
        
        self.gravityBehavior.addItem(imageView)
        self.collisionBehavior.addItem(imageView)
        
        let pushBehavior = UIPushBehavior(items: [imageView], mode: .instantaneous)
        pushBehavior.pushDirection = .init(dx: Double.random(in: -0.5...0.5), dy: 0)
        self.animator.addBehavior(pushBehavior)
      }
      
    }
    
  }
  
}

extension EmitterView.Content {
  fileprivate var image: UIImage {
    switch self {
    case let .image(image):
      return image
    case let .text(string, size):
      let defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: CGFloat(size))
      ]
      return NSAttributedString(string: "\(string)", attributes: defaultAttributes).image()
    }
  }
}

extension NSAttributedString {
  fileprivate func image() -> UIImage {
    return UIGraphicsImageRenderer(size: size()).image { _ in
      self.draw(at: .zero)
    }
  }
}
