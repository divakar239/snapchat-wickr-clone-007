/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    //MARK: IBOutlets and IBActions
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    @IBAction func signUp(sender: AnyObject) {
        
        // First we try to login the user
        
        PFUser.logInWithUsernameInBackground(userName.text!, password: password.text!) { (user, error) in
            
            
            if self.userName.text == "" || self.password.text == ""{
                
             
                self.displayAlert("ERROR:", message:"Invalid credentials")
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                

            }
            
            else if let error = error {
            
              
                // This means that there was an error while the user ried to login => that the user is trying to signUp. So we assign the properties of the new user.
                
                
                // Creating an indicator when the button is hit
                
                self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
                self.activityIndicator.center = self.view.center
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                
                self.view.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()

                // Storing the values when user sgn uos
                
                var user = PFUser()
                user.username = self.userName.text!
                user.password = self.password.text!
                
                user.signUpInBackgroundWithBlock({ (succeeded, error) in
                    
                    if let error = error{
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        // SignUp failed
                        
                        let errorString = error.userInfo["error"]! as! String
                        self.displayAlert("ERROR:", message: errorString)
                        
                    }
                    else{
                        print("Hi")
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                       
                            self.performSegueWithIdentifier("ShowUserTable", sender: self)
                        
                    }
                })
            }
            else{
                
                
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()

                
                print("bye")
                
                        self.performSegueWithIdentifier("ShowUserTable", sender: self)
                
                }
            }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil{
            
            //self.performSegueWithIdentifier("ShowUserTable", sender: self)
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
       
        self.navigationController?.navigationBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Cretae an Alert
    
    func displayAlert(title: String,message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }


}
