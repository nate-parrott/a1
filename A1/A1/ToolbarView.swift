//
//  ToolbarView.swift
//  A1
//
//  Created by Nate Parrott on 5/21/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class ToolbarView: UIView {

    @IBAction func back(sender: UIButton) {
        delegate?.toolbarPressedBack(ToolbarView: self)
    }
    
    @IBAction func share(sender: UIButton) {
        delegate?.toolbarPressedShare(ToolbarView: self)
    }
    
    weak var delegate: ToolbarDelegate?
}

protocol ToolbarDelegate: class {
    func toolbarPressedBack(ToolbarView _: ToolbarView)
    func toolbarPressedShare(ToolbarView _: ToolbarView)
}
