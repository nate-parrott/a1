//
//  Easing.swift
//  A1
//
//  Created by Nate Parrott on 3/22/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

func easeInOutQuad(_ t: CGFloat) -> CGFloat {
    // from https://gist.github.com/gre/1650294
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}
