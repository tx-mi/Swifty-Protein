//
//  TouchIDViewController.swift
//  Swifty Protein
//
//  Created by Morgane on 18/06/2019.
//  Copyright © 2019 Morgane DUBUS. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class TouchIDViewController: UIViewController {
    
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteAllEntities("Molecules")
        deleteAllEntities("Atoms")
        goButton.isEnabled = true
    }
    
    @IBAction func loginWithTouchID(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        goButton.isEnabled = false
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login to Swifty Protein", reply: { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "TouchIDToProteinsList", sender: self)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.goButton.isEnabled = true
                    }
                    alert(view: self, message: "Authentication failed")
                }
            })
        }
        else {
            goButton.isEnabled = true
            alert(view: self, message: "Touch ID is not available on your device")
        }
    }
    
}
