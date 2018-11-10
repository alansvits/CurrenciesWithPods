//
//  ViewController.swift
//  Currencies
//
//  Created by Stas Shetko on 2/11/18.
//  Copyright © 2018 Stas Shetko. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let PB_URL = "https://api.privatbank.ua/p24api/exchange_rates?json"

    @IBOutlet weak var PBTableView: UITableView!
    @IBOutlet weak var NBUTableView: UITableView!
    @IBOutlet weak var PBDateLabel: UILabel!
    @IBOutlet weak var NBUDateLabel: UILabel!
    
    var attriburedText = NSAttributedString()
    var datePickerDate = Date()
    var exchangeRatesArray: [RateData]?
    
    @IBAction func showDatePicker(_ sender: UIButton) {
        
        sender.setImage(UIImage(imageLiteralResourceName: "icons8-calendar-96 (1)"), for: UIControl.State.normal)

        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverId") as! DatePickerViewController
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender // button
        popController.popoverPresentationController?.sourceRect = sender.bounds
        
        // present the popover
        self.present(popController, animated: true) {
            popController.datePicker.date = self.datePickerDate
            popController.datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        }
//        self.present(popController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDateLabel()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    //MARK: - NBU tableview source delegate methods
    
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
    
    //MARK: - UIPopoverPresentationControllerDelegate methods
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        let button = popoverPresentationController.sourceView as! UIButton
        button.setImage(UIImage(imageLiteralResourceName: "icons8-calendar-96"), for: .normal)
        
        userSelectedDate(attriburedText.string)
        
        if popoverPresentationController.sourceView == view.viewWithTag(1) {
            PBDateLabel.attributedText = self.attriburedText
        }
        if popoverPresentationController.sourceView == view.viewWithTag(2) {
            NBUDateLabel.attributedText = self.attriburedText
        }
    }
    
}

private extension ViewController {
    @objc func datePickerValueChanged(datePicker: UIDatePicker) {
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy"
        
        let dateValue = dateformatter.string(from: datePicker.date)
        let attributedString = NSAttributedString(string: dateValue,
                                                  attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        self.attriburedText = attributedString
        datePickerDate = datePicker.date
    }
    
    func setUpDateLabel() {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy"
        
        let dateValue = dateformatter.string(from: Date())
        let attributedString = NSAttributedString(string: dateValue,
                                                  attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        PBDateLabel.attributedText = attributedString
        NBUDateLabel.attributedText = attributedString
    }
    
    func userSelectedDate(_ date: String) {
        let params: [String: String] = ["date": date]
        getExchangeRates(url: PB_URL, parameters: params)
    }
    
}

//MARK: Networking

 private extension ViewController {
    
    func getExchangeRates(url: String, parameters: [String: String]) {
        print(url)
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            
            if response.result.isSuccess {
                print("Success! Got the rate data")
                let exchangeRate = JSON(response.result.value!)
//                print(exchangeRate)
                //TODO: UPDATE UI
                self.updateCurrencyData(json: exchangeRate)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
            
        }
        
    }
    
}

//MARK: JSON parsing

private extension ViewController {
    
    func updateCurrencyData(json: JSON) {
        
        let tempResult = json["exchangeRate"].arrayValue
        print("exchange rate is: \(tempResult)")
        
        var ratesArray = [RateData]()
        for item in tempResult {
            if item["saleRate"].double != nil {
                
                let tempRateData = RateData(currency: item["currency"].stringValue,
                                            saleRateNBU: item["saleRateNB"].doubleValue,
                                            purchaseRateNBU: item["purchaseRateNB"].doubleValue,
                                            saleRatePB: item["saleRate"].double,
                                            purchaseRatePB: item["purchaseRate"].double)
                ratesArray.append(tempRateData)
                print(tempRateData)
            }
        }
    }
    
}
