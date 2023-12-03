//
//  Extentions.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 26/11/2023.
//

import Foundation
import UIKit

extension UIView {
    
    var width : CGFloat{
        return self.frame.size.width
    }
    
    var height : CGFloat{
        return self.frame.size.height
    }
    
    var top : CGFloat{
        return self.frame.origin.y
    }
    
    var bottom : CGFloat{
        return self.frame.size.height + self.frame.origin.y
    }
    
    var left : CGFloat{
        return self.frame.origin.x
    }
    
    var right : CGFloat{
        return self.frame.size.width + self.frame.origin.x
    }
}
