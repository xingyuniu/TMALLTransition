//
//  YLPresentationController.swift
//  Transition
//
//  Created by Mr yldany on 16/3/21.
//  Copyright © 2016年 YL. All rights reserved.
//


import UIKit

class YLPresentationController: UIPresentationController {
    
    //MARK:- properties
    
    
    //MARK:- life cycle
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        setupView()
    }
}

//MARK:- 设置modal控制器的属性
extension YLPresentationController {
    private func setupView() {
        containerView?.backgroundColor = UIColor.blackColor()
        // 设置modal的view的大小
        let width = containerView!.bounds.size.width
        let height = UIScreen.mainScreen().bounds.height * 0.6
        let y = containerView!.bounds.height * 0.4
        presentedView()?.frame = CGRect(x: 0, y: y, width: width, height: height)
}
    
    
}