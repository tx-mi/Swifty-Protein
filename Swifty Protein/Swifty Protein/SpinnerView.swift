//
//  SpinnerView.swift
//  Swifty Protein
//
//  Created by Morgane on 30/06/2019.
//  Copyright © 2019 Morgane DUBUS. All rights reserved.
//

import Foundation
import UIKit


class SpinnerView: UIView {
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        DispatchQueue.main.async {
             UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        initSpinnerView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSpinnerView() {
        self.backgroundColor = .white
        activityView.color = UIColor(red: 235.0/255.0, green: 70.0/255.0, blue: 145.0/255.0, alpha: 1)
        activityView.center = self.center
        activityView.hidesWhenStopped = true
    }
    
    public func startSpinning() {
        activityView.startAnimating()
        self.addSubview(activityView)
    }
    
    public func stopSpinning() {
        activityView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

    }
}
