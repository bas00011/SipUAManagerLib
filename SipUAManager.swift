import Foundation

var answerCall: Bool = false

struct theLinphone {
    static var lc: OpaquePointer?
    static var call: OpaquePointer?
    
    static var lct: LinphoneCoreVTable?
    static var manager: SipUAManager?
}
var sipRegistrationStatus: SipRegistrationStatus = SipRegistrationStatus.unknown

var registrationStateChanged: LinphoneCoreRegistrationStateChangedCb  = {
    (lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: _LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) in
    
    switch state{
    case LinphoneRegistrationNone: /**<Initial state for registrations */
        NSLog("LinphoneRegistrationNone")
        sipRegistrationStatus = .unknown
        
    case LinphoneRegistrationProgress:
        NSLog("LinphoneRegistrationProgress")
        sipRegistrationStatus = .unknown
        
    case LinphoneRegistrationOk:
        NSLog("LinphoneRegistrationOk")
        sipRegistrationStatus = .ok
        
    case LinphoneRegistrationCleared:
        NSLog("LinphoneRegistrationCleared")
        sipRegistrationStatus = .unknown
        
    case LinphoneRegistrationFailed:
        NSLog("LinphoneRegistrationFailed")
        sipRegistrationStatus = .fail
        
    default:
        NSLog("Unkown registration state")
    }
    
    } as LinphoneCoreRegistrationStateChangedCb

let callStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    
    switch callSate{
    case LinphoneCallIncomingReceived: /**<This is a new incoming call */
        NSLog("callStateChanged: LinphoneCallIncomingReceived")
        
        if answerCall{
            ms_usleep(3 * 1000 * 1000); // Wait 3 seconds to pickup
            linphone_core_accept_call(lc, call)
        }
        
    case LinphoneCallStreamsRunning: /**<The media streams are established and running*/
        NSLog("callStateChanged: LinphoneCallStreamsRunning")
        
    case LinphoneCallError: /**<The call encountered an error*/
        NSLog("callStateChanged: LinphoneCallError")
        
    default:
        NSLog("Default call state")
    }
}


public class SipUAManager {
    
    static var iterateTimer: Timer?
    
    init() {
        
        theLinphone.lct = LinphoneCoreVTable()
        
        
        // Enable debug log to stdout
        linphone_core_set_log_file(nil)
        linphone_core_set_log_level(ORTP_DEBUG)
        
        // Load config
        let configFilename = documentFile("linphonerc222")
        let factoryConfigFilename = bundleFile("linphonerc-factory")
        
        let configFilenamePtr: UnsafePointer<Int8> = configFilename.cString(using: String.Encoding.utf8.rawValue)!
        let factoryConfigFilenamePtr: UnsafePointer<Int8> = factoryConfigFilename.cString(using: String.Encoding.utf8.rawValue)!
        let lpConfig = lp_config_new_with_factory(configFilenamePtr, factoryConfigFilenamePtr)
        
        // Set Callback
        theLinphone.lct?.registration_state_changed = registrationStateChanged
        theLinphone.lct?.call_state_changed = callStateChanged
        
        theLinphone.lc = linphone_core_new_with_config(&theLinphone.lct!, lpConfig, nil)
        
        // Set ring asset
        let ringbackPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("/ringback.wav").absoluteString
        linphone_core_set_ringback(theLinphone.lc, ringbackPath)
        
        let localRing = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("/toy-mono.wav").absoluteString
        linphone_core_set_ring(theLinphone.lc, localRing)
        if let proxyConfig = self.setIdentify() {
            self.register(proxyConfig)
        }
    }
    
    fileprivate func bundleFile(_ file: NSString) -> NSString{
        return Bundle.main.path(forResource: file.deletingPathExtension, ofType: file.pathExtension)! as NSString
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    
    //
    // This is the start point to know how linphone library works.
    //
    func demo() {
        makeCall()
        //        autoPickImcomingCall()
        idle()
    }
    
    func makeCall(){
        linphone_core_enable_logs(nil);
        //        let call = theLinphone.call
        
        var running = true
        //        var cl = theLinphone.call
        let calleeAccount = "+66616379305"
        let callphone = (calleeAccount as String).utf8CString
        //        var call = UnsafeMutablePointer<Int8>(callphone)
        let proxyCfg = setIdentify()
        if UserData.getCallAccount() != nil {
            //            calleeAccount = UserData.getCallAccount()!
        }
        
        
        
        if let lc = theLinphone.lc {
            linphone_core_invite(lc, calleeAccount)
            linphone_core_get_config(lc)
        }
        //        let policy:LinphoneVideoPolicy
        linphone_core_refresh_registers(theLinphone.lc);
        //        let i=0;
        while (running ) {
            linphone_core_iterate(theLinphone.lc);
            usleep(100000);
        }
        //        while running {
        //            linphone_core_iterate(theLinphone.lc);
        //            ms_usleep(200);
        //        }
        //        if (cl != nil) && linphone_call_get_state(cl) != LinphoneCallEnd {
        //            /* terminate the call */
        //            print("Terminating the call...\n");
        //            linphone_core_terminate_call(theLinphone.lc,cl);
        //            /*at this stage we don't need the call object */
        //            linphone_call_unref(cl);
        //
        //        }
    }
    
    func receiveCall(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
        //        shutdown()
    }
    
    func idle(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
        //        shutdown()
    }
    
    func setIdentify() -> OpaquePointer? {
        
        // Reference: http://www.linphone.org/docs/liblinphone/group__registration__tutorials.html
        
        //        let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
        //        let dict = NSDictionary(contentsOfFile: path!)
        let account = UserData.getSipAccount()!
        let password = UserData.getSipPassword()!
        let domain = UserData.getProxyAddress()!
        let port = UserData.getProxyPort()!
        let identity = "sip:" + account + "@" + domain + ":" + port;
        
        
        /*create proxy config*/
        let proxy_cfg = linphone_proxy_config_new();
        
        /*parse identity*/
        let from = linphone_address_new(identity);
        
        if (from == nil){
            NSLog("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org");
            return nil
        }
        
        let info=linphone_auth_info_new(linphone_address_get_username(from), nil, password, nil, domain, domain); /*create authentication structure from identity*/
       
        linphone_core_add_auth_info(theLinphone.lc, info); /*add authentication info to LinphoneCore*/
        
        // configure proxy entries
        linphone_proxy_config_set_identity(proxy_cfg, identity); /*set identity with user name and domain*/
        let server_addr = String(cString: linphone_address_get_domain(from)); /*extract domain address from identity*/
        
        
        
        
        linphone_address_destroy(from); /*release resource*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, server_addr); /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 0); /* activate registration for this proxy config*/
        linphone_core_add_proxy_config(theLinphone.lc, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(theLinphone.lc, proxy_cfg); /*set to default proxy*/
//        let transports :UnsafePointer<LCSipTransports>
        var tTransport = ""
        if UserData.getTransPort() != nil {
            tTransport = UserData.getTransPort()!
        }
        var transport = LCSipTransports()
        switch tTransport {
        case "udp":
            if port != nil{
                transport.udp_port = (port as NSString).intValue
            }else{
                transport.udp_port = 5060
            }
            break
        case "tcp":
            if port != nil{
                transport.tcp_port = (port as NSString).intValue
            }else{
                transport.tcp_port = 5060
            }
            break
        default:
            if port != nil{
            transport.tls_port = (port as NSString).intValue
            }else{
            transport.tls_port = 5061
            }
            break
        }
        let config = linphone_core_get_default_proxy_config(theLinphone.lc!);
        linphone_core_set_sip_transports(theLinphone.lc, &transport)
        linphone_core_get_sip_transports(theLinphone.lc, &transport)
        print(linphone_core_get_user_data(theLinphone.lc)) 
        let state:LinphoneRegistrationState
        //get status regis
        state = linphone_proxy_config_get_state(config)
        print(state)
       
        
        return proxy_cfg!
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_enable_register(proxy_cfg, 1); /* activate registration for this proxy config*/
    }
    
    func shutdown(){
        NSLog("Shutdown..")
        
        let proxy_cfg = linphone_core_get_default_proxy_config(theLinphone.lc); /* get default proxy config*/
        linphone_proxy_config_edit(proxy_cfg); /*start editing proxy configuration*/
        linphone_proxy_config_enable_register(proxy_cfg, 0); /*de-activate registration for this proxy config*/
        linphone_proxy_config_done(proxy_cfg); /*initiate REGISTER with expire = 0*/
        while(linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationCleared){
            linphone_core_iterate(theLinphone.lc); /*to make sure we receive call backs before shutting down*/
            ms_usleep(50000);
        }
        
        linphone_core_destroy(theLinphone.lc);
    }
    
    @objc func iterate(){
        if let lc = theLinphone.lc{
            linphone_core_iterate(lc); /* first iterate initiates registration */
        }
    }
    
    fileprivate func setTimer(){
        SipUAManager.iterateTimer = Timer.scheduledTimer(
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
}
