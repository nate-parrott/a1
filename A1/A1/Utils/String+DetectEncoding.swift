//
//  String+DetectEncoding.swift
//  A1
//
//  Created by Nate Parrott on 6/20/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import Foundation

extension Data {
    var stringByDetectingEncoding: String? {
        // TODO
        return String(data: self, encoding: .utf8)
//        var str: NSString?
//        NSString.stringEncoding(for: self, encodingOptions: nil, convertedString: AutoreleasingUnsafeMutablePointer(&str), usedLossyConversion: nil)
//        if let s = str {
//            return s.copy() as! String
//        } else {
//            return nil
//        }
    }
}
