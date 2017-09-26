//
//  ViewController.swift
//  linphone-trial
//
//  Created by Cody Liu on 6/7/16.
//  Copyright © 2016 WiAdvance. All rights reserved.
//

import UIKit
let manager = SipUAManager()

class RegisterViewController: UIViewController {
    @IBOutlet weak var tUserName:UITextField!
    @IBOutlet weak var tPassword:UITextField!
    @IBOutlet weak var tDomain:UITextField!
    @IBOutlet weak var tPort:UITextField!
    var mTransport:String!
    @IBOutlet weak var sender:UISegmentedControl!
    @IBAction func onChangeTransport(sender:Int){
        switch sender {
        case 0:
            mTransport = "udp"
            //UDP
            break
        case 1:
            mTransport = "tcp"
            //TCP
            break
        default:
            mTransport = "tls"
           //TLS
            break
        }

    }
    
    
    @IBAction func onClickRegister(){
        UserData.setSipAccount(tUserName.text!)
        UserData.setSipPassword(tPassword.text!)
        UserData.setProxyAddress(tDomain.text!)
        
        if tPort.text! != nil {
            UserData.setProxyPort(tPort.text!)
        }
        if mTransport != nil{
        UserData.setTransPort(mTransport)
        }
        print(sender.selectedSegmentIndex)
        manager.setIdentify()
        print(sipRegistrationStatus)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.onChangeTransport(sender: sender.selectedSegmentIndex)
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

