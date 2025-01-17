//
//  PopoverFiltersViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 03/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import SwiftRangeSlider

// Protocol used for delegating the filter changes to the class that implements it
protocol PopoverFiltersProtocol : class {
    func didChangeFiltersAllCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool)
    func didChangeFiltersSomeCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool, categories: [String])
}

// The class used for providind the functionalitites of the Filtering ViewControler
class PopoverFiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CategoriesListCellProtocol {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var timeIntervalSlider: RangeSlider!
    @IBOutlet weak var orderByPicker: UIPickerView!
    @IBOutlet weak var onlyAvailableSwitch: UISwitch!
    @IBOutlet weak var allCategoriesSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var navigationLogo: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    var categories: [String] = []
    var maxDistance: Int = 50
    var minTime: String = "08:00"
    var maxTime: String = "24:00"
    var sortBy: Int = 0
    var onlyAvailableOffers: Bool = true
    var allCategories: Bool = true
    var selections: [Bool] = []
    var noSelections = 0
    
    @IBOutlet weak var categoriesStackView: UIStackView!
    weak var delegate: PopoverFiltersProtocol?

    // Function called upon the completion of the loading
    override func viewDidLoad() {
        super.viewDidLoad()
        orderByPicker.delegate = self
        orderByPicker.dataSource = self
        timeIntervalSlider.lowerValue = Double(Utils.instance.getTimeInt(time: minTime))
        timeIntervalSlider.upperValue = Double(Utils.instance.getTimeInt(time: maxTime))
        timeIntervalLabel.text = "\(minTime)-\(maxTime)"
        distanceSlider.value = Float(maxDistance)
        distanceLabel.text = "\(maxDistance) km"
        orderByPicker.selectRow(sortBy, inComponent: 0, animated: false)
        onlyAvailableSwitch.isOn = onlyAvailableOffers
        if categories.count <= 1 {
            categoriesStackView.isHidden = true
        } else {
            categoriesStackView.isHidden = false
            tableView.delegate = self
            tableView.dataSource = self
            allCategoriesSwitch.isOn = allCategories
            tableView.isHidden = allCategories ? true : false
        }
    }
    
    // Function called upon the initiation of the view's rendering
    override func viewWillAppear(_ animated: Bool) {
        customizeAppearance()
    }
    
    // Function that performs the customisation of the visual elements
    func customizeAppearance() {
        navigationView.backgroundColor = Utils.instance.mainColour
        mainView.backgroundColor = Utils.instance.backgroundColour
        mainTitleLabel.text = Utils.instance.mainTitle
        bottomView.backgroundColor = Utils.instance.mainColour
        searchButton.backgroundColor = Utils.instance.mainColour
        distanceSlider.tintColor = Utils.instance.mainColour
        timeIntervalSlider.trackHighlightTintColor = Utils.instance.mainColour
        if Utils.instance.navigationLogo != "" {
            let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(Utils.instance.navigationLogo)").path
            navigationLogo.image = UIImage(contentsOfFile: filename)
        } else {
            navigationLogo.image = UIImage(named: "banWhite")
        }
    }

    // Functions that manage the table and the content cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell") as? CategoriesTableViewCell else {
            return CategoriesTableViewCell()
        }
        cell.delegate = self
        cell.tag = indexPath.row
        cell.categorySwitch.setOn(selections[indexPath.row], animated: false)
        cell.configureCell(categories[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Functions that manage the picker view and its elements
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
            case 0:
                return "Distance"
            case 1:
                return "Rating"
            default:
                return UserDefaults.standard.value(forKey: "type") as! String == "location" ? "Discount" : "Price"
        }
    }
    
    @IBAction func distanceSliderChanged(_ sender: Any) {
        distanceLabel.text = "\(Int(distanceSlider.value)) km"
    }
    
    @IBAction func timeIntervalSliderChanged(_ sender: Any) {
        timeIntervalLabel.text = "\(Utils.instance.getTime(time: Int(timeIntervalSlider.lowerValue)))-\(Utils.instance.getTime(time: Int(timeIntervalSlider.upperValue)))"
    }
    
    @IBAction func allCategoriesSwitchChanged(_ sender: Any) {
        tableView.isHidden = allCategoriesSwitch.isOn ? true : false
    }
    
    func didSwitch(_ tag: Int) {
        if (selections[tag] == true) {
            noSelections -= 1
            selections[tag] = false
        } else {
            noSelections += 1
            selections[tag] = true
        }
    }
    
    // Functions that saves the filtering options selected by the user
    @IBAction func dismissPopover(_ sender: Any) {
        if categories.count == 1 {
            delegate?.didChangeFiltersAllCategories(distance: Int(distanceSlider.value), lowerTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.lowerValue)), higherTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.upperValue)), sortBy: orderByPicker.selectedRow(inComponent: 0), onlyAvailableOffers: onlyAvailableSwitch.isOn)
            dismiss(animated: true, completion: nil)
        } else {
            if allCategoriesSwitch.isOn {
                delegate?.didChangeFiltersAllCategories(distance: Int(distanceSlider.value), lowerTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.lowerValue)), higherTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.upperValue)), sortBy: orderByPicker.selectedRow(inComponent: 0), onlyAvailableOffers: onlyAvailableSwitch.isOn)
                dismiss(animated: true, completion: nil)
            } else {
                if noSelections == 0 {
                    let alertView = UIAlertController(title: "No category selected",
                                                      message: "Please select at least one category" as String, preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alertView.addAction(okAction)
                    self.present(alertView, animated: true, completion: nil)
                } else {
                    var selectedCategories: [String] = []
                    for (index, value) in selections.enumerated() {
                        if value == true {
                            selectedCategories.append(categories[index])
                        }
                    }
                    delegate?.didChangeFiltersSomeCategories(distance: Int(distanceSlider.value), lowerTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.lowerValue)), higherTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.upperValue)), sortBy: orderByPicker.selectedRow(inComponent: 0), onlyAvailableOffers: onlyAvailableSwitch.isOn, categories: selectedCategories)
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
