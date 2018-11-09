//
//  ViewController.swift
//  Currencies
//
//  Created by Stas Shetko on 2/11/18.
//  Copyright © 2018 Stas Shetko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBAction func showDatePicker(_ sender: Any) {

        performSegue(withIdentifier: "popOver", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popOver" {
            let destinationVC = segue.destination
            if let popoverVC = destinationVC.popoverPresentationController {
                popoverVC.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

}

