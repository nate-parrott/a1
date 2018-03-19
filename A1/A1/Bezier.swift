//
//  Bezier.swift
//  A1
//
//  Created by Nate Parrott on 3/19/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

func bezierCurve(from: CGPoint, control1: CGPoint, to: CGPoint, control2: CGPoint) -> ((CGFloat) -> CGFloat) {
    return { (t: CGFloat) -> CGFloat in
        return lerp(start: lerp(start: from, end: control1, t: t), end: lerp(start: control2, end: to, t: t), t:t).y
    }
}

func decelerationFunction(factor: CGFloat) -> ((CGFloat) -> CGFloat) {
    let bezier = bezierCurve(from: CGPoint.zero, control1: CGPoint(x: 1, y: factor) * 0.4, to: CGPoint(x: 1, y: 1), control2: CGPoint(x: 1 - 0.4, y: 1))
    return { (t: CGFloat) -> CGFloat in
        return bezier(t) / factor
    }
}
