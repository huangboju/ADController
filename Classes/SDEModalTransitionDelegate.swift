//
//  Copyright © 2016年 xiAo_Ju. All rights reserved.
//

class SDEModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    var animatedTransitioning: UIViewControllerAnimatedTransitioning {
        switch ADConfig.shared.transitionType {
        case .overlayVertical, .overlayHorizontal:
            return OverlayAnimationController()
        case .bottomToTop, .topToBottom, .leftToRight, .rightToLeft:
            return SliderAnimationController()
        }
    }

    func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatedTransitioning
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatedTransitioning
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
