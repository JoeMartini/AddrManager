//
//  FirstViewController.swift
//  AddrManager
//
//  Created by Martini Wang on 14/10/16.
//  Copyright (c) 2014年 Martini Wang. All rights reserved.
//

import UIKit

class ContactlistTableViewController: UITableViewController {

    @IBOutlet var contactListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        contactListTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProfiles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ContactCell")
        cell.textLabel.text = allProfiles[indexPath.row]!["Name"]!
        println(cell.description)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(tableView.cellForRowAtIndexPath(indexPath)?.textLabel.text)
        var contactProfileVC:ContactProfileViewController = ContactProfileViewController()
        contactProfileVC.profileIndex = indexPath.row
        self.navigationController?.pushViewController(contactProfileVC, animated: true)
    }
    
    @IBAction func addDone(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func addCancle(segue:UIStoryboardSegue) {
        
    }


}

