//
//  DropMenuButton.swift
//  DropDownMenu
//
//  Created by Marcos Paulo Rodrigues Castro on 9/1/16.
//  Copyright © 2016 HackTech. All rights reserved.
//

import UIKit

class DropMenuButton: UIButton, UITableViewDelegate, UITableViewDataSource
{
    var items = [String]()
    var table = UITableView()
    var act = [() -> (Void)]()
    
    var rowHeight: CGFloat = 50
    var rowWidth: CGFloat = 150
    
    var superSuperView = UIView()
    
    func showItems()
    {
        
        fixLayout()
  
        if(table.alpha == 0)
        {
            self.layer.zPosition = 1
            UIView.animate(withDuration: 0.3
                , animations: { 
                    self.table.alpha = 1;
            })
          
        }
        
        else
        {
            
            UIView.animate(withDuration: 0.3
                , animations: {
                    self.table.alpha = 0;
                    self.layer.zPosition = 0
            })
    
        }
        
    }

    
    func initMenu(_ items: [String], actions: [() -> (Void)])
    {
        self.items = items
        self.act = actions
        
        var resp = self as UIResponder
        
        while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
        {
            resp = resp.next!
            
        }
        
        if let vc = resp as? UIViewController{
            superSuperView = vc.view
        }
        else if let vc = resp as? UITableViewCell{
            superSuperView = vc
        }
        
        table = UITableView()
        table.rowHeight = rowHeight
        table.delegate = self
        table.dataSource = self
        table.isUserInteractionEnabled = true
        table.alpha = 0
        table.separatorColor = self.backgroundColor
        superSuperView.addSubview(table)
        self.addTarget(self, action:#selector(DropMenuButton.showItems), for: .touchUpInside)
        
        //table.registerNib(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "cell")
       
    }
    
    func initMenu(_ items: [String])
    {
        self.items = items
        
        var resp = self as UIResponder
        
        while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
        {
            resp = resp.next!
            
        }
        
        if let vc = resp as? UIViewController{
            
            superSuperView = vc.view
        }
        else if let vc = resp as? UITableViewCell{
            
            superSuperView = vc
            
        }
        
        table = UITableView()
        table.rowHeight = rowHeight
        table.delegate = self
        table.dataSource = self
        table.isUserInteractionEnabled = true
        table.alpha = 0
        table.separatorColor = self.backgroundColor
        superSuperView.addSubview(table)
        self.addTarget(self, action:#selector(DropMenuButton.showItems), for: .touchUpInside)
        
        //table.registerNib(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    
    
    func fixLayout()
    {
        
        var tableFrameHeight = CGFloat()
        
        tableFrameHeight = rowHeight * CGFloat(self.act.count) - 1
//        table.layer.cornerRadius = 10
        table.frame = CGRect(x: 225, y: 20 + rowHeight, width: 150, height:tableFrameHeight)
        table.rowHeight = rowHeight
        table.layer.borderColor = UIColor.lightGray.cgColor
        table.layer.borderWidth = 1
        table.layer.shadowOpacity = 0.6
        table.clipsToBounds = true
        
        table.reloadData()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setNeedsDisplay()
        fixLayout()
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        self.setTitle(items[(indexPath as NSIndexPath).row], for: UIControlState())
        self.setTitle(items[(indexPath as NSIndexPath).row], for: UIControlState.highlighted)
        self.setTitle(items[(indexPath as NSIndexPath).row], for: UIControlState.selected)

        if self.act.count > 1
        {
            self.act[indexPath.row]()
        }

        showItems()
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let itemLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: rowHeight))
        itemLabel.textAlignment = NSTextAlignment.center
        itemLabel.text = items[(indexPath as NSIndexPath).row]
        itemLabel.font = UIFont.init(name: "Futura", size: 19.0)
        itemLabel.textColor = UIColor.white
        
        let bgColorView = UIView()
        
        // TODO: SET COLOUR DYNAMICALLY
        bgColorView.backgroundColor = UIColor.white
        
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: rowWidth, height: rowHeight))
        cell.backgroundColor = UIColor.init(red: 16/255.0, green: 173/255.0, blue: 203/255.0, alpha: 1)
        cell.selectedBackgroundView = bgColorView
        cell.separatorInset = UIEdgeInsetsMake(0, rowWidth, 0, rowWidth)
        cell.addSubview(itemLabel)
        
        
        return cell
    }

}
