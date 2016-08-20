//
//  UserTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Divakar Kapil on 2016-08-17.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse


class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    var userNames = [String]()
    var recipientUsernames : String = ""
    var imageFiles = [PFFile]()
    var imageToBeDisplayed = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NSTimer to regulate the receiving of images.
        
        _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: (#selector(UserTableViewController.checkForMessage)), userInfo: nil, repeats: true)
        
        

        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!) // We don't want the current user to appear.
     
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if let objects = objects{
                
                self.userNames.removeAll(keepCapacity: true)
                
                for object in objects{
                    if let user = object as? PFUser{
                    
                        self.userNames.append(user["username"] as! String)
                        //print("done")
                        self.tableView.reloadData()
                    }
                }
            }
            
            
            
        })
       // tableView.reloadData()
        
        
    }
        
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userNames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel!.text = userNames[indexPath.row]
        //print("in table")
        return cell
    }
    

    // Code to perform actions when a row is selected.
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Storing the currently chosen user from the table
        
        recipientUsernames = userNames[indexPath.row]
        
        // Code to choose image from the library
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    
    
    //Code to perform actions once an image is chosen for a row
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let imageToSend = PFObject(className: "image")
        imageToSend["picture"] = PFFile(name: "pic.jpg", data: UIImageJPEGRepresentation(image, 0.5)!)
        imageToSend["senderUsername"] = PFUser.currentUser()?.username
        imageToSend["recipientUsername"] = recipientUsernames
        
        //To make the acl permissions public so that any user can remove the images he/she recieives
        let acl = PFACL()
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        
        imageToSend.ACL = acl  // very important code , allows any user to manipulate the database so that we can delete the object.
        
        imageToSend.saveInBackground()
        
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logout"{
            
            PFUser.logOut()
        
        }

   }
    
    func checkForMessage(){
        
        var username = "Unknown User"
        var query = PFQuery(className:"image")
        
        if let currentUser = PFUser.currentUser()?.username{
        
            query.whereKey("recipientUsername", equalTo: currentUser)
        
        
        query.findObjectsInBackgroundWithBlock { (images, error) in
            
            if let images = images {
                
                //self.imageFiles.removeAll(keepCapacity: true)
                
                //print(images[0].valueForKey("senderUsername")!)
                
                
                for image in images{
                    
                    self.imageFiles.append(image.valueForKey("picture") as! PFFile)
                    //self.imageFiles[0].getDataInBackgroundWithBlock({ (data, error) in
                    image.valueForKey("picture")!.getDataInBackgroundWithBlock({ (data, error) in
                    
                        if  error == nil{
                            
                            //var imageToBeDisplayed = UIImage(data: data!)!
                            self.imageToBeDisplayed = UIImage(data:data!)!
                            username = image["senderUsername"] as! String
                            
                            let alert = UIAlertController(title:"You have a message from:", message: username, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                                
                                // Manually creating first UIImageView
                                
                                let background = UIImageView(frame:CGRectMake(0, 0, self.view.frame.width, self.view.frame.height
                                    ))
                                
                                background.backgroundColor = UIColor.blackColor()
                                background.alpha = 0.8
                                background.tag = 10
                                background.contentMode = UIViewContentMode.ScaleAspectFit
                                self.view.addSubview(background)
                                
                                // Manually creating second UIImageView
                                let displayImage = UIImageView(frame:CGRectMake(0, 0, self.view.frame.width, self.view.frame.height
                                    ))
                                
                                // PFFile is a general file format of any object, to get the actual data in it we need the method getDataInBackgroundWithBlock
                                
                                
                                displayImage.image = self.imageToBeDisplayed  //self.imageToBeDisplayed
                                displayImage.tag = 10
                                displayImage.contentMode = UIViewContentMode.ScaleAspectFit
                                self.view.addSubview(displayImage)
                                
                                // delete the object from parse
                                image.deleteInBackgroundWithBlock({ (success, error) in
                                    if error == nil{ print("Deleted")}
                                    else{print("failed")}
                                })
                                
                                // Another NSTimer to prevent the alert from displaying continually.
                                
                                //print(image.valueForKey("senderUsername")!)


                                _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(UserTableViewController.hideMessage), userInfo: nil, repeats: false)
                                
                                
                                }
                                
                                )))
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        }
                        
                    })
                    
            }
            
            
        }
        
        
    }
        }
    
        
    
}
    func hideMessage(){
        
        // We are looping through all the tags of the subviews present in this view and removing the ones with tag 10, namely the background and display image.
        
        for subView in self.view.subviews{
            
            if subView.tag == 10{
                
                subView.removeFromSuperview()
            }
        }
        
        
        
    }

}