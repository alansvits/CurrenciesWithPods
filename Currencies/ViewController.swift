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
    let PB_TODAY_RATES_URL = "https://api.privatbank.ua/p24api/pubinfo?exchange&json&coursid=11"
    let NB_URL = "https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json"
    
    @IBOutlet weak var PBTableView: UITableView!
    @IBOutlet weak var NBUTableView: UITableView!
    @IBOutlet weak var PBDateLabel: UILabel!
    @IBOutlet weak var NBUDateLabel: UILabel!
    
    var attriburedText = NSAttributedString()
    var datePickerDate = Date()
    var PBexchangeRatesArray: [RateData]?
    var NBexchangeRatesArray: [NBRateData]?
    var PBTableConstraint: NSLayoutConstraint?
    
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
            popController.datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -4, to: Date())
            popController.datePicker.date = self.datePickerDate
            popController.datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
            popController.datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), for: .touchDown)
        }
    }
    
    @IBAction func getTodayRates(_ sender: Any) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy"
        
        let dateValue = dateformatter.string(from: Date())
        userSelectedDateFor(PB_TODAY_RATES_URL, with: nil)
        let stringDate = dateValue
        let formattedString = stringDate.replacingOccurrences(of: ".", with: "")
        let formattdStringForRequest = formattedString[4..<formattedString.count] + formattedString[2..<4] + formattedString[0..<2]
        userSelectedDateFor(NB_URL, with: formattdStringForRequest)
        let attributedString = NSAttributedString(string: dateValue,
                                                  attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        attriburedText = attributedString
        PBDateLabel.attributedText = attriburedText
        NBUDateLabel.attributedText = attriburedText
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDateLabel()
        userSelectedDateFor(PB_TODAY_RATES_URL, with: nil)

        let stringDate = attriburedText.string
        let formattedString = stringDate.replacingOccurrences(of: ".", with: "")
        let formattdStringForRequest = formattedString[4..<formattedString.count] + formattedString[2..<4] + formattedString[0..<2]
        userSelectedDateFor(NB_URL, with: formattdStringForRequest)
        
        PBTableConstraint = NSLayoutConstraint(item: PBTableView,
                                               attribute: .height,
                                               relatedBy: .equal,
                                               toItem: nil,
                                               attribute: .notAnAttribute,
                                               multiplier: 0,
                                               constant: 150)
        PBTableView.addConstraint(PBTableConstraint!)
        fixPBTableLandscapeMode()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        fixPBTableLandscapeMode()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //MARK: - NBU tableview data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == NBUTableView {
            
            if let NBRatesArray = NBexchangeRatesArray {
                return NBRatesArray.count
            } else { return 5 }
            
        } else if tableView == PBTableView {
            
            if let PBRatesArray = PBexchangeRatesArray {
                return PBRatesArray.count
            } else { return 5 }
            
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == NBUTableView {
            
            let cell = NBUTableView.dequeueReusableCell(withIdentifier: "NBUCell") as! NBUTableViewCell
            if let NBRates = NBexchangeRatesArray {
                cell.currencyName.text = NBRates[indexPath.row].currencyName
                cell.priceLabel.text = String(format: "%.2f", Double(getMultiplierFor(NBRates[indexPath.row].currency)) * NBRates[indexPath.row].saleRate)  + "UAH"
                cell.unitsLabel.text = "\(String(getMultiplierFor(NBRates[indexPath.row].currency)))" + NBRates[indexPath.row].currency
                return cell
            } else { return UITableViewCell() }
            
        } else if tableView == PBTableView {
            
            let cell = PBTableView.dequeueReusableCell(withIdentifier: "PBCell") as! PBTableViewCell
            if let PBRates = PBexchangeRatesArray {
                cell.currencyLabel.text = PBRates[indexPath.row].currency
                cell.purchaseRateLabel.text = String(format: "%.3f", PBRates[indexPath.row].purchaseRatePB)
                cell.saleRateLabel.text = String(format: "%.3f", PBRates[indexPath.row].saleRatePB)
                return cell
            } else {
                return UITableViewCell()
            }
            
        } else { return UITableViewCell() }
        
    }
    
    //MARK: - NBU tableview  delegate methods
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == NBUTableView {
            let color = indexPath.row % 2 == 0 ? UIColor.white : UIColor(red: 238.0/255, green: 245.0/255, blue: 240.0/255, alpha: 1.0)
            cell.backgroundColor = color
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == PBTableView {
            let seletedCell = PBexchangeRatesArray![indexPath.row]
            var currencySign = seletedCell.currency
            if currencySign == "PLZ" { currencySign = "PLN" }
//            if currencySign == "RUR" { currencySign = "RUR" }
            if let index = NBexchangeRatesArray?.firstIndex(where: { $0.currency == currencySign }) {
                NBUTableView.selectRow(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .top)
            }
        }
        if tableView == NBUTableView {
            let seletedCell = NBexchangeRatesArray![indexPath.row]
            var currencySign = seletedCell.currency
            if currencySign == "PLN" { currencySign = "PLZ" }
            if let index = PBexchangeRatesArray?.firstIndex(where: { $0.currency == currencySign }) {
                PBTableView.selectRow(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .top)
            }
        }
    }
    
    //MARK: - UIPopoverPresentationControllerDelegate methods
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        let button = popoverPresentationController.sourceView as! UIButton
        button.setImage(UIImage(imageLiteralResourceName: "icons8-calendar-96"), for: .normal)
        
        if popoverPresentationController.sourceView == view.viewWithTag(1) {
            PBDateLabel.attributedText = self.attriburedText
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd.MM.yyyy"
            
            let dateValue = dateformatter.string(from: Date())
            if attriburedText.string == dateValue {
                userSelectedDateFor(PB_TODAY_RATES_URL, with: nil)
            } else {
                userSelectedDateFor(PB_URL, with: attriburedText.string)
            }
        }
        if popoverPresentationController.sourceView == view.viewWithTag(2) {
            let stringDate = attriburedText.string
            let formattedString = stringDate.replacingOccurrences(of: ".", with: "")
            let formattdStringForRequest = formattedString[4..<formattedString.count] + formattedString[2..<4] + formattedString[0..<2]
            userSelectedDateFor(NB_URL, with: formattdStringForRequest)
            NBUDateLabel.attributedText = self.attriburedText
        }
    }
    
    //MARK: - HELPER methods
    
    private func fixPBTableLandscapeMode() {
        if UIDevice.current.orientation.isLandscape {
            PBTableConstraint?.isActive = false
        } else {
            PBTableConstraint?.isActive = true
        }
    }
    
    private func sortPBTableSourceArray(_ array: [RateData]) -> [RateData] {
        var resultArr = array
        var eur = [RateData]()
        var usd = [RateData]()
        var rub = [RateData]()
        
        for item in array {
            if item.currency == "EUR" {
                resultArr.removeAll(where: {$0.currency == "EUR"})
            } else if item.currency == "USD" {
                resultArr.removeAll(where: {$0.currency == "USD"})
            } else if item.currency == "RUB" {
                resultArr.removeAll(where: {$0.currency == "RUB"})
            }
        }
        for item in array {
            if item.currency == "EUR" {
                eur.append(item)
            } else if item.currency == "USD" {
                usd.append(item)
            } else if item.currency == "RUB" {
                rub.append(item)
            }
        }
        
        resultArr = eur + usd + rub + resultArr
        return resultArr
    }
    
    private func getMultiplierFor(_ currency: String) -> Int {
        switch currency {
        case "RUB": return 10
        case "VND": return 1000
        case "IDR": return 10000
        case "AMD": return 100
        case "LBP": return 1000
        case "IQD": return 100
        case "TWD": return 100
        case "PKR": return 100
        case "KZT": return 100
        case "IRR": return 1000
        case "INR": return 10
        case "THB": return 100
        case "UZS": return 100
        case "JPY": return 10
        case "BDT": return 100
        case "HUF": return 1000
        case "DZD": return 100
        case "KGS": return 100
        default: return 1
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
        attriburedText = attributedString
        PBDateLabel.attributedText = attributedString
        NBUDateLabel.attributedText = attributedString
    }
    
    func userSelectedDateFor(_ url: String, with date: String? = nil) {
        if let date = date {
            let params: [String: String] = ["date": date]
            getExchangeRates(url: url, parameters: params)
        } else {
            getExchangeRates(url: url)
        }
    }
    
}

//MARK: Networking
//"The Internet connection appears to be offline."
private extension ViewController {
    
    func getExchangeRates(url: String, parameters: [String: String]? = nil) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            
            if response.result.isSuccess {
                let exchangeRate = JSON(response.result.value!)
                
                if url == self.PB_TODAY_RATES_URL { self.PBTodayRateDataUpdateCurrency(json: exchangeRate) }
                if url == self.PB_URL { self.PBRateDataUpdateCurrency(json: exchangeRate) }
                if url == self.NB_URL { self.NBRateDataUpdateCurrency(json: exchangeRate) }
                
            } else {
                // create the alert
                let alert = UIAlertController(title: "Error", message: "The Internet connection appears to be offline.", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
}


//MARK: JSON parsing

private extension ViewController {
    
    func PBRateDataUpdateCurrency(json: JSON) {
        let tempResult = json["exchangeRate"].arrayValue
        var ratesArray = [RateData]()
        for item in tempResult {
            if item["saleRate"].double != nil {
                let tempRateData = RateData(currency: item["currency"].stringValue,
                                            saleRatePB: item["saleRate"].doubleValue,
                                            purchaseRatePB: item["purchaseRate"].doubleValue)
                ratesArray.append(tempRateData)
            }
        }
        PBexchangeRatesArray = sortPBTableSourceArray(ratesArray)
        PBTableView.reloadData()
        PBTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
    func PBTodayRateDataUpdateCurrency(json: JSON) {
        var ratesArray = [RateData]()
        for item in json.arrayValue {
            if item["ccy"].stringValue == "BTC" { continue }
            if item["ccy"].stringValue == "RUR" {
                let tempRateData = RateData(currency: "RUB",
                                            saleRatePB: item["sale"].doubleValue,
                                            purchaseRatePB: item["buy"].doubleValue)
                ratesArray.append(tempRateData)
                continue
            }
            let tempRateData = RateData(currency: item["ccy"].stringValue,
                                        saleRatePB: item["sale"].doubleValue,
                                        purchaseRatePB: item["buy"].doubleValue)
            ratesArray.append(tempRateData)
        }
        PBexchangeRatesArray = sortPBTableSourceArray(ratesArray)
        PBTableView.reloadData()
    }
    
    func NBRateDataUpdateCurrency(json: JSON) {
        let tempResult = json.arrayValue
        var ratesArray = [NBRateData]()
        for item in tempResult {
            if item["cc"].stringValue == "XDR" { continue }
            let tempRateData = NBRateData(currency: item["cc"].stringValue,
                                          currencyName: item["txt"].stringValue,
                                          saleRate: item["rate"].doubleValue)
            ratesArray.append(tempRateData)
        }
        NBexchangeRatesArray = ratesArray
        NBUTableView.reloadData()
    }
    
}
