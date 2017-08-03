//
//  PopoverFiltersViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 03/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import SwiftRangeSlider

protocol PopoverFiltersProtocol : class {
    func didChangeFiltersAllCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, onlyAvailableOffers: Bool)
    func didChangeFiltersSomeCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, onlyAvailableOffers: Bool, categories: [String])
}

class PopoverFiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CategoriesListCellProtocol {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var timeIntervalSlider: RangeSlider!
    @IBOutlet weak var onlyAvailableSwitch: UISwitch!
    @IBOutlet weak var allCategoriesSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    var categories: [String] = ["Pubs", "Bars", "Venues", "Happy Hours", "Hahaha", "Hohoho", "Hihihi"]
    var selections: [Bool] = []
    var noSelections = 0
    weak var delegate: PopoverFiltersProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        selections = Array(repeating: false, count: categories.count)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell") as? CategoriesTableViewCell {
            
            cell.delegate = self
            cell.tag = indexPath.row
            cell.categorySwitch.setOn(selections[indexPath.row], animated: false)
            cell.configureCell(categories[indexPath.row])
            
            return cell
        } else {
            return CategoriesTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func distanceSliderChanged(_ sender: Any) {
        distanceLabel.text = "\(Int(distanceSlider.value)) km"
    }
    
    @IBAction func timeIntervalSliderChanged(_ sender: Any) {
        timeIntervalLabel.text = "\(Utils.instance.getTime(time: Int(timeIntervalSlider.lowerValue)))-\(Utils.instance.getTime(time: Int(timeIntervalSlider.upperValue)))"
    }
    
    @IBAction func allCategoriesSwitchChanged(_ sender: Any) {
        if !allCategoriesSwitch.isOn {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
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
    
    @IBAction func dismissPopover(_ sender: Any) {
        if allCategoriesSwitch.isOn {
            delegate?.didChangeFiltersAllCategories(distance: Int(distanceSlider.value), lowerTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.lowerValue)), higherTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.upperValue)), onlyAvailableOffers: true)
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
                delegate?.didChangeFiltersSomeCategories(distance: Int(distanceSlider.value), lowerTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.lowerValue)), higherTimeInterval: Utils.instance.getTime(time: Int(timeIntervalSlider.upperValue)), onlyAvailableOffers: true, categories: selectedCategories)
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
