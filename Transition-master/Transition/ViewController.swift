//
//  ViewController.swift
//  Transition
//
//  Created by Mr yldany on 16/3/21.
//  Copyright © 2016年 YL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK:- Lazy properties
    
    /// 控制器view截屏
    
    private lazy var screenShot: UIView = {
        let screenSI = self.view.snapshotViewAfterScreenUpdates(false)
        return screenSI
    }()
    /// 转场动画管理器
    private lazy var transitionAnimator: TransitionAnimator = TransitionAnimator(fromView: self.screenShot)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.hidden = false
    }
    
    //MARK:- life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        view.hidden = true
        let modalVC = ModalViewController()
        modalVC.modalPresentationStyle = .Custom
        modalVC.transitioningDelegate = transitionAnimator
        
        presentViewController(modalVC, animated: true, completion: nil)
    }

}

//MARK:- setup UI
extension ViewController {
    private func setupUI() {
        view.backgroundColor = UIColor.orangeColor()
    }
}

