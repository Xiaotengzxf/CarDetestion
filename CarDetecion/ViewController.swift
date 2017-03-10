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

class ViewController: UIViewController , UIViewControllerTransitioningDelegate , UIViewControllerAnimatedTransitioning , UITableViewDataSource , UITableViewDelegate{
    
    var modalPresentingType: ModalPresentingType?
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 244 + WIDTH * 350 / 1080.0)
        addBannerView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addBannerView() -> Void {
        let banner = KCScrollingDisplayView(frame: CGRect(x: 0, y: WIDTH * 350 / 1080.0, width: WIDTH, height: 200))
        banner.pageControlAliment = .right
        banner.scrollDirection = .vertical
        banner.autoScrollTimeInterval = 5.0
        banner.titleArr = ["感谢您的支持，如果下载的","如果代码在使用过程中出现问题","您可以在GitHub上联系我"]
        banner.imageUrlArr = ["https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                              "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                              "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"]
        banner.clickCurrentIndexItemCallback = {
            (currentIndex: Int) in
            print(String(format: "点击了%d", currentIndex))
        }
        
        tableView.tableHeaderView?.addSubview(banner)
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
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
        let viewController = segue.destination
        viewController.transitioningDelegate = self
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

