//
//  ModalViewController.swift
//  Transition
//
//  Created by Mr yldany on 16/3/21.
//  Copyright © 2016年 YL. All rights reserved.
//

import UIKit
import SnapKit

class ModalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}

//MARK:- Setup UI
extension ModalViewController {
    private func setupUI() {
        view.backgroundColor = UIColor.greenColor()
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "1")
        imageView.contentMode = .ScaleToFill
        view.addSubview(imageView)
        
        imageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        // 长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPress")
        view.addGestureRecognizer(longPress)
        
//        let tableView = UITableView()
//        tableView.dataSource = self
//        tableView.frame = view.bounds
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        view.addSubview(tableView)
//        tableView.snp_remakeConstraints { (make) -> Void in
//            make.top.equalTo(view.snp_top)
//            make.bottom.equalTo(view.snp_bottom)
//            make.left.equalTo(view.snp_left)
//            make.right.equalTo(view.snp_right)
//        }
    }
    
    @objc private func longPress() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ModalViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.textLabel?.text = "cell---\(indexPath.row)"
        return cell
    }
    
}


