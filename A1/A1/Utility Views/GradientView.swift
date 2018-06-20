import UIKit

class GradientView : UIView {
    override class var layerClass: Swift.AnyClass { return CAGradientLayer.self }
    
    func set(topColor: UIColor, bottomColor: UIColor) {
        (self.layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
