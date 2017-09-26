//
//  UserData.swift
//  SipUAManagerLib
//
//  Created by Entronica on 8/31/17.
//  Copyright © 2017 Entronica. All rights reserved.
//

import Foundation

class UserData{
    static let preference = UserDefaults.standard
    
    static fileprivate let SIP_ACCOUNT_KEY: String = "SIP_ACCOUNT_KEY"
    static fileprivate let SIP_PASSWORD_KEY: String = "SIP_PASSWORD_KEY"
    static fileprivate let SIP_PROXY_ADDRESS_KEY: String = "SIP_PROXY_ADDRESS_KEY"
    static fileprivate let SIP_PROXY_PORT_KEY: String = "SIP_PROXY_PORT_KEY"
    static fileprivate let SIP_TRANSPORT_KEY: String = "SIP_TRANSPORT_KEY"
    
    static fileprivate let CALL_ACCOUNT_KEY: String = "CALL_ACCOUNT_KEY"
    static fileprivate let STATUS_ACCOUNT_KEY: String = "STATUS_ACCOUNT_KEY"
    
    static func setSipAccount(_ sipAccount: String){
        preference.setValue(sipAccount, forKey: SIP_ACCOUNT_KEY)
        preference.synchronize()
    }
    
    static func getSipAccount() -> String?{
        return preference.string(forKey: SIP_ACCOUNT_KEY)
    }
    
    static func setSipPassword(_ sipPassword: String){
        preference.setValue(sipPassword, forKey: SIP_PASSWORD_KEY)
        preference.synchronize()
    }
    
    static func getSipPassword() -> String?{
        return preference.string(forKey: SIP_PASSWORD_KEY)
    }
    
    static func setProxyAddress(_ proxyAddress: String){
        preference.setValue(proxyAddress, forKey: SIP_PROXY_ADDRESS_KEY)
        preference.synchronize()
    }
    
    static func getProxyAddress() -> String?{
        return preference.string(forKey: SIP_PROXY_ADDRESS_KEY)
    }
    
    static func setProxyPort(_ proxyPort: String){
        preference.setValue(proxyPort, forKey: SIP_PROXY_PORT_KEY)
        preference.synchronize()
    }
    
    static func getProxyPort() -> String?{
        return preference.string(forKey: SIP_PROXY_PORT_KEY)
    }
    
    static func setTransPort(_ proxyPort: String){
        preference.setValue(proxyPort, forKey: SIP_TRANSPORT_KEY)
        preference.synchronize()
    }
    
    static func getTransPort() -> String?{
        return preference.string(forKey: SIP_TRANSPORT_KEY)
    }
    
    
    static func setCallAccount(_ callAccount: String){
        preference.setValue(callAccount, forKey: CALL_ACCOUNT_KEY)
        preference.synchronize()
    }
    
    static func getCallAccount() -> String?{
        return preference.string(forKey: CALL_ACCOUNT_KEY)
    }
    
    static func setStatusAccount(_ statusAccount: String){
        preference.setValue(statusAccount, forKey: STATUS_ACCOUNT_KEY)
        preference.synchronize()
    }
    
    static func getStatusAccount() -> String?{
        return preference.string(forKey: STATUS_ACCOUNT_KEY)
    }
    static func clear(){
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    
    
}
