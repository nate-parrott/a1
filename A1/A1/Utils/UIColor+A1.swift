import UIKit

extension UIColor {
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r, g, b, a)
        } else if getWhite(&r, alpha: &a) {
            g = r
            b = r
            return (r, g, b, a)
        }
        return (0,0,0,0)
    }
    var hsva: (h: CGFloat, s: CGFloat, v: CGFloat, a: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var v: CGFloat = 0
        var a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &v, alpha: &a) {
            return (h,s,v,a)
        } else if getWhite(&v, alpha: &a) {
            return (0, 0, v, a)
        }
        return (0,0,0,0)
    }
}
