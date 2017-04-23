//
//  Copyright © 2016年 Wimagguc. All rights reserved.
//

import UIKit

protocol CustomIOSAlertViewDelegate {
    func customIOS7dialogButtonTouchUpInside(alertView: AnyObject, clickedButtonAtIndex: NSInteger)
}

class ADAlert: UIView {
    var parentView: UIView?
    var dialogView: UIView?
    var containerView: UIView?
    var delegate: CustomIOSAlertViewDelegate?
    var buttonTitles: [String]?
    var useMotionEffects: Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
