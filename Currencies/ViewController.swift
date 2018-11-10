//
//  ViewController.swift
//  Currencies
//
//  Created by Stas Shetko on 2/11/18.
//  Copyright © 2018 Stas Shetko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var PBTableView: UITableView!
    @IBOutlet weak var NBUTableView: UITableView!
    
    
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

    //MARK: - NBU tableview delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == NBUTableView {
            return 5
        } else if tableView == PBTableView {
            return 4
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == NBUTableView {
            let cell = NBUTableView.dequeueReusableCell(withIdentifier: "NBUCell")
            return cell!
        } else if tableView == PBTableView {
            let cell = PBTableView.dequeueReusableCell(withIdentifier: "PBCell")
            return cell!
        } else {
            return UITableViewCell()
        }
    }
    
}

