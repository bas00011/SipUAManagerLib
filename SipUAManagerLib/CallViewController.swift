//
//  CallViewController.swift
//  linphone-swift-demo
//
//  Created by Entronica on 9/13/17.
//  Copyright © 2017 WiAdvance. All rights reserved.
//

import UIKit



class CallViewController: UIViewController {
    @IBOutlet weak var status:UILabel!
    @IBOutlet weak var callAcoount : UITextField!
    
    @IBAction func onClickCall(){
        UserData.setCallAccount(callAcoount.text!)
        manager.makeCall()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        switch sipRegistrationStatus {
        case .ok:
            NSLog("sipRegistrationStatus: OK")
            self.status.text = "REGISTRATION"
            
        case .fail:
            NSLog("sipRegistrationStatus: FAIL")
            self.status.text = "FAIL"
            
        case .unknown:
            NSLog("sipRegistrationStatus: UNKNOWN")
            self.status.text = "UNKNOWN"
            
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
