//
//  ViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

enum ModalPresentingType {
    case Present, Dismiss
}

class ViewController: UIViewController , UIViewControllerTransitioningDelegate , UIViewControllerAnimatedTransitioning{
    
    var modalPresentingType: ModalPresentingType?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func test(_ sender: Any) {
//        let cameraViewController = CameraViewController(croppingEnabled: false, allowsLibraryAccess: true) { [weak self] image, asset in
//            
//            self?.dismiss(animated: true, completion: nil)
//        }
//        cameraViewController.transitioningDelegate = self
//        self.present(cameraViewController, animated: true) { 
//            
//        }
        
    }
    
    // 转场动画
    
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let toViewController = transitionContext.viewController(forKey: .to)
        let fromViewController = transitionContext.viewController(forKey: .from)
        
        var destView: UIView!
        var destTransfrom = CGAffineTransform.identity
        
        if modalPresentingType == ModalPresentingType.Present {
            destView = toViewController!.view
            destView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
            containerView.addSubview(toViewController!.view)
        } else if modalPresentingType == ModalPresentingType.Dismiss {
            destView = fromViewController!.view
            destTransfrom = CGAffineTransform(rotationAngle: -CGFloat(M_PI_2))
            containerView.insertSubview(toViewController!.view, belowSubview: fromViewController!.view)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0,
                                   options: UIViewAnimationOptions.curveLinear, animations: {
                                    destView.transform = destTransfrom
        }, completion: {completed in
            transitionContext.completeTransition(true)
        })
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    //UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        modalPresentingType = .Present
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        modalPresentingType = .Dismiss
        return self
    }

}

