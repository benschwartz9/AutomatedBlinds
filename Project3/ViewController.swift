//
//  ViewController.swift
//  Project3
//
//  Created by Ben Schwartz on 11/9/19.
//  Copyright © 2019 Ben. All rights reserved.
//

//http://studyswift.blogspot.com/2016/03/communication-between-ios-device-client.html
//http://studyraspberrypi.blogspot.com/2016/03/sending-rsa-encrypted-message-ios.html
//http://studyswift.blogspot.com/2016/03/sending-rsa-encrypted-message-from-ios_3.html
//https://forums.developer.apple.com/thread/82768
//https://codewithchris.com/deploy-your-app-on-an-iphone/

import UIKit



class ViewController: UIViewController, StreamDelegate{
    
    
    //Button
    var buttonConnect : UIButton!
    //var buttonGetKey : UIButton!
    var buttonSendMsg : UIButton!
    var buttonQuit : UIButton!
    var buttonOpen : UIButton!
    var datePickerOpen : UIDatePicker!
    var datePickerClose : UIDatePicker!
    
    //Label
    var label : UILabel!
    var labelConnection : UILabel!
    var openLabel : UILabel!
    var closeLabel : UILabel!
    
    //Socket server
    let addr = "192.168.113.1"
    let port = 9876
    
    //Network variables
    var inStream : InputStream?
    var outStream: OutputStream?
    
    //Data received
    var buffer = [UInt8](repeating: 0, count: 2000)//[UInt8](unsafeUninitializedCapacity: 2000, initializingWith: 0)
    
    var inStreamLength : Int!
    
    var keyString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtonSetup()
        
        LabelSetup()
    }
    
    func setupButton(button:UIButton){
        button.layer.cornerRadius = 15
        button.center.x = self.view.center.x
        button.alpha = 1.0
    }
    
    func activateButton(button:UIButton){
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemGray5, for: UIControl.State.highlighted)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 15

    }
    
    func deactivateButton(button:UIButton){
        button.setTitleColor(UIColor.systemGray, for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemGray4, for: UIControl.State.highlighted)
        button.backgroundColor = UIColor.systemGray5
    }
    
    //Button Functions
    func ButtonSetup() {
        buttonConnect = UIButton(frame: CGRect(x: 0, y: 150, width:300, height:30))// height 139   width: 108, height: 41))
        buttonConnect.setTitle("Connect", for: UIControl.State.normal)
        buttonConnect.addTarget(self, action:#selector(btnConnectPressed), for: UIControl.Event.touchUpInside)
        buttonConnect.addTarget(self, action:#selector(btnGetKey), for: UIControl.Event.touchUpInsid
        setupButton(button: buttonConnect)
        activateButton(button: buttonConnect)
        view.addSubview(buttonConnect)
        
        buttonOpen = UIButton(frame: CGRect(x: 0, y: 190, width: 300, height: 30))
        buttonOpen.setTitle("Open", for: UIControl.State.normal)
        buttonOpen.addTarget(self, action:#selector(btnOpen), for: UIControl.Event.touchUpInside)
        setupButton(button: buttonOpen)
        deactivateButton(button: buttonOpen)
        buttonOpen.isEnabled = false
        view.addSubview(buttonOpen)
        
//        buttonGetKey = UIButton(frame: CGRect(x: 0, y: 190, width: 300, height: 30))
//        buttonGetKey.setTitle("Get server's public key", for: UIControl.State.normal)
//        buttonGetKey.addTarget(self, action:#selector(btnGetKey), for: UIControl.Event.touchUpInside)
//        setupButton(button: buttonGetKey)
//        deactivateButton(button: buttonGetKey)
//        buttonGetKey.isEnabled = false
//        view.addSubview(buttonGetKey)
        
        buttonSendMsg = UIButton(frame: CGRect(x: 0, y: 230, width: 300, height: 30))
        buttonSendMsg.setTitle("Close", for:UIControl.State.normal)//"Send encrypted message", for: UIControl.State.normal)
        buttonSendMsg.addTarget(self, action:#selector(btnSendMsg), for: UIControl.Event.touchUpInside)
        setupButton(button: buttonSendMsg)
        deactivateButton(button: buttonSendMsg)
        buttonSendMsg.isEnabled = false
        view.addSubview(buttonSendMsg)
        
        datePickerOpen = UIDatePicker(frame: CGRect(x: 0, y: 500, width: 150, height: 50))
        datePickerOpen.center.x = self.view.center.x + 70
        datePickerOpen.timeZone = NSTimeZone.local
        datePickerOpen.datePickerMode = UIDatePicker.Mode.time
        datePickerOpen.addTarget(self, action:#selector(sendOpenDate), for: UIControl.Event.valueChanged)
        datePickerOpen.isHidden = true
        view.addSubview(datePickerOpen)

        datePickerClose = UIDatePicker(frame: CGRect(x: 0, y: 550, width: 150, height: 50))
        datePickerClose.center.x = self.view.center.x + 70
        datePickerClose.timeZone = NSTimeZone.local
        datePickerClose.datePickerMode = UIDatePicker.Mode.time
        datePickerClose.addTarget(self, action:#selector(sendCloseDate), for: UIControl.Event.valueChanged)
        datePickerClose.isHidden = true
        view.addSubview(datePickerClose)
        
        buttonQuit = UIButton(frame: CGRect(x: 0, y: 270, width: 300, height: 30))
        buttonQuit.setTitle("Send \"Quit\"", for: UIControl.State.normal)
        buttonQuit.addTarget(self, action:#selector(btnQuitPressed), for: UIControl.Event.touchUpInside)
        setupButton(button: buttonQuit)
        deactivateButton(button: buttonQuit)
        buttonQuit.isEnabled = false
        view.addSubview(buttonQuit)
    }
    
    @objc func sendOpenDate(sender: UIButton){
        let date = datePickerOpen.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour!
        let minute = components.minute!
        
        let message = "SetTimeOpen " + String(hour) + " " + String(minute)
        let data = message.data(using: .utf8)!
        _ = data.withUnsafeBytes {bytes in
            outStream?.write(bytes, maxLength: data.count)
        }
        
        var strMin = ""
        if (minute < 10){
            strMin = "0"+String(minute)
        } else {
            strMin = String(minute)
        }
        
        if (hour > 12) {
            label.text = "Updated open time to " + String(hour%12) + ":" + strMin + " p.m."
        } else if (hour == 12){
            label.text = "Updated open time to 12:" + strMin + " p.m."
        } else if (hour == 0){
            label.text = "Updated open time to 12:" + strMin + " a.m."
        } else {
            label.text = "Updated open time to " + String(hour) + ":" + strMin + " a.m."
        }
    }
    
    @objc func sendCloseDate(sender: UIButton){
        let date = datePickerClose.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour!
        let minute = components.minute!
        
        let message = "SetTimeClose " + String(hour) + " " + String(minute)
        let data = message.data(using: .utf8)!
        _ = data.withUnsafeBytes {bytes in
            outStream?.write(bytes, maxLength: data.count)
        }
        
        var strMin = ""
        if (minute < 10){
            strMin = "0"+String(minute)
        } else {
            strMin = String(minute)
        }
        
        if (hour > 12) {
            label.text = "Updated close time to " + String(hour%12) + ":" + strMin + " p.m."
        } else if (hour == 12){
            label.text = "Updated close time to 12:" + strMin + " p.m."
        } else if (hour == 0){
            label.text = "Updated close time to 12:" + strMin + " a.m."
        } else {
            label.text = "Updated close time to " + String(hour) + ":" + strMin + " a.m."
        }
    }
    
    @objc func btnConnectPressed(sender: UIButton) {
        NetworkEnable()
    
        //buttonConnect.alpha = 0.3
        buttonConnect.setTitle("Connecting", for: UIControl.State.normal)
        buttonConnect.isEnabled = false
    }
    @objc func btnGetKey(sender: UIButton) {
        let data = "Client: OK".data(using: .utf8)!
        _ = data.withUnsafeBytes {bytes in
            outStream?.write(bytes, maxLength: data.count)
        }
        
        //let data : NSData = "Client: OK".data(using: .utf8) //usingEncoding: NSUTF8StringEncoding)! as NSData
        //sdata.withUnsafeBytes{_ in outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)}
        //outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    @objc func btnOpen(sender: UIButton){
        let data = "Open".data(using: .utf8)!
        _ = data.withUnsafeBytes {bytes in
            outStream?.write(bytes, maxLength: data.count)
        }
    }
    @objc func btnSendMsg(sender: UIButton) {
        
        let message = "Close"//"Secret message from iPhone!!"
        
        let data = message.data(using: .utf8)!//(message as NSString).dataUsingEncoding(NSUTF8StringEncoding)!

        _ = data.withUnsafeBytes {bytes in
            outStream?.write(bytes, maxLength: data.count)
        }
        
        //Encrypt Message
//        // tag name to access the stored public key in keychain
//        let TAG_PUBLIC_KEY = "com.mycompany.tag_public"
//
//        let encryptStr = "encrypted_message="
//        let encryptStrData = encryptStr.data(using: .utf8)//usingEncoding: NSUTF8StringEncoding)!
//
//        print(keyString)
//
//        let encryptedData = RSAUtils.encryptWithRSAPublicKey(data!, pubkeyBase64: keyString, keychainTag: TAG_PUBLIC_KEY)!
//
//        let length = encryptStrData!.count + encryptedData.count
//
//        var array = [UInt8](repeating: 0, count: length)//[UInt8](unsafeUninitializedCapacity: length, initializingWith: 0)
//        encryptStrData!.copyBytes(to:&array, count: encryptStrData!.count)//encryptStrData.getBytes(&array, length: encryptStrData.length)
//        encryptedData.copyBytes(to:&array+encryptStrData!.count, count: encryptedData.count)//encryptedData.getBytes(&array+encryptStrData.length, length: encryptedData.length)
//
//        outStream?.write(UnsafePointer<UInt8>(array), maxLength: length)
        
        
        
//        deactivateButton(button: buttonSendMsg)
//        buttonSendMsg.isEnabled = false
//        deactivateButton(button: buttonOpen)
//        buttonOpen.isEnabled = false
//        activateButton(button: buttonQuit)
//        buttonQuit.isEnabled = true
        
        //label.text = "Encrypted message sent"
    }
    @objc func btnQuitPressed(sender: UIButton) {
        let data = "Quit".data(using: .utf8)!
        _ = data.withUnsafeBytes {bytes in
            outStream?.write(bytes, maxLength: data.count)
        }
        //let data : Data = "Quit".data(using: <#String.Encoding#>)! as Data//(usingEncoding: NSUTF8StringEncoding)! as NSData
        //data.withUnsafeBytes{_ in outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)}
        
        deactivateButton(button: buttonOpen)
        buttonOpen.isEnabled = false
        
        deactivateButton(button: buttonSendMsg)
        buttonSendMsg.isEnabled = false
        
        deactivateButton(button: buttonQuit)
        buttonQuit.isEnabled = false
    }
    
    //Label setup function
    func LabelSetup() {
        label = UILabel(frame: CGRect(x: 0,y: 0,width: 300,height: 150))
        label.center = CGPoint(x: view.center.x, y: view.center.y+100)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0 //Multi-lines
        label.font = UIFont(name: "Helvetica-Bold", size: 20)
        view.addSubview(label)
        
        openLabel = UILabel(frame: CGRect(x: 0,y: 500,width: 150,height: 50))
        //openLabel.center = CGPoint(x: view.center.x, y: view.center.y+100)
        openLabel.textAlignment = NSTextAlignment.center
        openLabel.numberOfLines = 0 //Multi-lines
        openLabel.font = UIFont(name: "Helvetica-Bold", size: 20)
        openLabel.text = "Open Time:"
        openLabel.isHidden = true
        view.addSubview(openLabel)

        closeLabel = UILabel(frame: CGRect(x: 0,y: 550,width: 150,height: 50))
        closeLabel.textAlignment = NSTextAlignment.center
        closeLabel.numberOfLines = 0 //Multi-lines
        closeLabel.font = UIFont(name: "Helvetica-Bold", size: 20)
        closeLabel.text = "Close Time:"
        closeLabel.isHidden = true
        view.addSubview(closeLabel)
        
        labelConnection = UILabel(frame: CGRect(x: 0,y: 0,width: 300,height: 30))
        labelConnection.center = view.center
        labelConnection.textAlignment = NSTextAlignment.center
        labelConnection.text = "Please connect to server"
        view.addSubview(labelConnection)
    }
    
    //Network functions
    func NetworkEnable() {
        
        //print("NetworkEnable")
        //print(addr)
        //print(port)
        Stream.getStreamsToHost(withName: addr, port: port, inputStream: &inStream, outputStream: &outStream)
        
        inStream?.delegate = self
        outStream?.delegate = self
        
        inStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        
        inStream?.open()
        outStream?.open()
        
        buffer = [UInt8](repeating: 0, count: 2000)//[UInt8](unsafeUninitializedCapacity: 2000, initializingWith: 0)
    }
    
    //func stream(aStream: Stream, handleEvent eventCode: Stream.Event) {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.endEncountered:
            print("EndEncountered")
            labelConnection.text = "Connection stopped by server"
            label.text = ""

            inStream?.close()
            inStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            outStream?.close()
            print("Stop outStream currentRunLoop")
            outStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            activateButton(button: buttonConnect)
            
            buttonConnect.setTitle("Connect", for: UIControl.State.normal)
            buttonConnect.isEnabled = true
            
            datePickerOpen.isHidden = true
            datePickerClose.isHidden = true
            openLabel.isHidden = true
            closeLabel.isHidden = true
            
            buffer.removeAll(keepingCapacity: true)
            keyString = ""
        case Stream.Event.errorOccurred:
            print("ErrorOccurred")
            
            inStream?.close()
            inStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            outStream?.close()
            outStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            labelConnection.text = "Failed to connect to server"
            activateButton(button: buttonConnect)
            buttonConnect.setTitle("Connect", for: UIControl.State.normal)
            buttonConnect.isEnabled = true
            
            deactivateButton(button: buttonSendMsg)
            buttonSendMsg.isEnabled = false
            deactivateButton(button: buttonOpen)
            buttonOpen.isEnabled = false
            deactivateButton(button: buttonQuit)
            buttonQuit.isEnabled = false
            datePickerOpen.isHidden = true
            datePickerClose.isHidden = true
            openLabel.isHidden = true
            closeLabel.isHidden = true
            
            label.text = ""
        case Stream.Event.hasBytesAvailable:
            print("HasBytesAvailable")
            
            if aStream == inStream {

                inStreamLength = inStream!.read(&buffer, maxLength: buffer.count)
                
                let bufferStr = NSString(bytes: &buffer, length: inStreamLength, encoding: String.Encoding.utf8.rawValue)! as String
                
                label.text = "Times Received"
                let receivedInfo = bufferStr.components(separatedBy: " ")
                
                if (receivedInfo.count > 1 && receivedInfo[0] != "Server" && receivedInfo[1] != "stopped\n") {
                    print(receivedInfo.count)
                    print(receivedInfo)
                    
                    let calendar = NSCalendar.current
                    var components = DateComponents()
                    components.hour = Int(receivedInfo[0])
                    components.minute = Int(receivedInfo[1])
                    datePickerOpen.setDate(calendar.date(from: components)!, animated: false)
                    
                    components.hour = Int(receivedInfo[2])
                    components.minute = Int(receivedInfo[3])
                    datePickerClose.setDate(calendar.date(from: components)!, animated: false)

                    
                    buttonConnect.layer.cornerRadius = 5
                    buttonConnect.backgroundColor = UIColor.systemGray
                    buttonConnect.setTitle("Connected", for: UIControl.State.normal)
                    
                    activateButton(button: buttonSendMsg)
                    buttonSendMsg.isEnabled = true

                    activateButton(button: buttonOpen)
                    buttonOpen.isEnabled = true

                    activateButton(button: buttonQuit)
                    buttonQuit.isEnabled = true

                    datePickerOpen.isHidden = false
                    datePickerClose.isHidden = false
                    openLabel.isHidden = false
                    closeLabel.isHidden = false
                }
//                if keyString == "" {
//                    label.text = "Public key received"
//                    keyString = getKeyStringFromPEMString(PEMString: bufferStr)
//                    //deactivateButton(button: buttonGetKey)
//                    //buttonGetKey.isEnabled = false
//
//                    activateButton(button: buttonSendMsg)
//                    buttonSendMsg.isEnabled = true
//
//                    activateButton(button: buttonOpen)
//                    buttonOpen.isEnabled = true
//
//                    activateButton(button: buttonQuit)
//                    buttonQuit.isEnabled = true
//
//                    datePickerOpen.isHidden = false
//                }
//                else {
//                    print(bufferStr)
//                }
                
            }
            
        case Stream.Event.hasSpaceAvailable:
            print("HasSpaceAvailable")
        //case Stream.Event.None:
        //    print("None")
        case Stream.Event.openCompleted:
            print("OpenCompleted")
//            labelConnection.text = "Connected to server"
//            //activateButton(button: buttonGetKey)
//            //buttonGetKey.isEnabled = true
//
//            //Custom Deactivate Button
//            buttonConnect.layer.cornerRadius = 5
//            buttonConnect.backgroundColor = UIColor.systemGray
//            buttonConnect.setTitle("Connected", for: UIControl.State.normal)
        default:
            print("Unknown")
        }
    }
    
    //Key function - remove header and footer
    func getKeyStringFromPEMString(PEMString: String) -> String {

        let keyArray = PEMString.components(separatedBy: "\n")//.componentsSeparatedByString("\n") //Remove new line characters
        
        var keyOutput : String = ""
        
        for item in keyArray {
            if !item.contains("-----") { //Example: -----BEGIN PUBLIC KEY-----
                keyOutput += item //Join the text together as a single string
            }
        }
        return keyOutput
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}













//
//
//
////
////  ViewController.swift
////  Project3
////
////  Created by Ben Schwartz on 11/9/19.
////  Copyright © 2019 Ben. All rights reserved.
////
//
////http://studyswift.blogspot.com/2016/03/communication-between-ios-device-client.html
////http://studyraspberrypi.blogspot.com/2016/03/sending-rsa-encrypted-message-ios.html
////http://studyswift.blogspot.com/2016/03/sending-rsa-encrypted-message-from-ios_3.html
////https://forums.developer.apple.com/thread/82768
////https://codewithchris.com/deploy-your-app-on-an-iphone/
//
//import UIKit
//
//
//
////https://blog.supereasyapps.com/how-to-create-round-buttons-using-ibdesignable-on-ios-11/
////@IBDesignable class RoundButton: UIButton {
////
////    override init(frame: CGRect) {
////        super.init(frame: frame)
////        sharedInit()
////    }
////
////    required init?(coder aDecoder: NSCoder) {
////        super.init(coder: aDecoder)
////        sharedInit()
////    }
////
////    override func prepareForInterfaceBuilder() {
////        sharedInit()
////    }
////
////    func sharedInit() {
////        refreshCorners(value: cornerRadius)
////    }
////
////
////    func refreshCorners(value: CGFloat) {
////        layer.cornerRadius = value
////    }
////
////    @IBInspectable var cornerRadius: CGFloat = 15 {
////        didSet {
////            refreshCorners(value: cornerRadius)
////        }
////    }
////
////}
//
//
//
//
//
//class ViewController: UIViewController, StreamDelegate{
//
//
//    //Button
//    var buttonConnect : UIButton!
//    var buttonGetKey : UIButton!
//    var buttonSendMsg : UIButton!
//    var buttonQuit : UIButton!
//
//    //Label
//    var label : UILabel!
//    var labelConnection : UILabel!
//
//    //Socket server
//    let addr = "192.168.113.1"
//    let port = 9876
//
//    //Network variables
//    var inStream : InputStream?
//    var outStream: OutputStream?
//
//    //Data received
//    var buffer = [UInt8](repeating: 0, count: 2000)//[UInt8](unsafeUninitializedCapacity: 2000, initializingWith: 0)
//
//    var inStreamLength : Int!
//
//    var keyString = ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        ButtonSetup()
//
//        LabelSetup()
//    }
//
//    func setupButton(button:UIButton){
//        button.layer.cornerRadius = 15
//        button.center.x = self.view.center.x
//        button.alpha = 1.0
//    }
//
//    func activateButton(button:UIButton){
//        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
//        button.setTitleColor(UIColor.systemGray5, for: UIControl.State.highlighted)
//        button.backgroundColor = UIColor.systemBlue
//        button.layer.cornerRadius = 15
//
//    }
//
//    func deactivateButton(button:UIButton){
//        button.setTitleColor(UIColor.systemGray, for: UIControl.State.normal)
//        button.setTitleColor(UIColor.systemGray4, for: UIControl.State.highlighted)
//        button.backgroundColor = UIColor.systemGray5
//    }
//
//    //Button Functions
//    func ButtonSetup() {
//        buttonConnect = UIButton(frame: CGRect(x: 0, y: 150, width:300, height:30))// height 139   width: 108, height: 41))
//        buttonConnect.setTitle("Connect", for: UIControl.State.normal)
//        buttonConnect.addTarget(self, action:#selector(btnConnectPressed), for: UIControl.Event.touchUpInside)
//        //buttonConnect.addTarget(self, action:#selector(btnGetKey), for: UIControl.Event.touchUpInside)
//        setupButton(button: buttonConnect)
//        activateButton(button: buttonConnect)
//        view.addSubview(buttonConnect)
//
////        buttonGetKey = UIButton(frame: CGRect(x: 0, y: 190, width: 300, height: 30))
////        buttonGetKey.setTitle("Get server's public key", for: UIControl.State.normal)
////        buttonGetKey.addTarget(self, action:#selector(btnGetKey), for: UIControl.Event.touchUpInside)
////        setupButton(button: buttonGetKey)
////        deactivateButton(button: buttonGetKey)
////        buttonGetKey.isEnabled = false
////        view.addSubview(buttonGetKey)
//
//        buttonSendMsg = UIButton(frame: CGRect(x: 0, y: 230, width: 300, height: 30))
//        buttonSendMsg.setTitle("Send encrypted message", for: UIControl.State.normal)
//        buttonSendMsg.addTarget(self, action:#selector(btnSendMsg), for: UIControl.Event.touchUpInside)
//        setupButton(button: buttonSendMsg)
//        deactivateButton(button: buttonSendMsg)
//        buttonSendMsg.isEnabled = false
//        view.addSubview(buttonSendMsg)
//
//        buttonQuit = UIButton(frame: CGRect(x: 0, y: 270, width: 300, height: 30))
//        buttonQuit.setTitle("Send \"Quit\"", for: UIControl.State.normal)
//        buttonQuit.addTarget(self, action:#selector(btnQuitPressed), for: UIControl.Event.touchUpInside)
//        setupButton(button: buttonQuit)
//        deactivateButton(button: buttonQuit)
//        buttonQuit.isEnabled = false
//        view.addSubview(buttonQuit)
//    }
//
//    @objc func btnConnectPressed(sender: UIButton) {
//        NetworkEnable()
//
//        //buttonConnect.alpha = 0.3
//        buttonConnect.setTitle("Connecting", for: UIControl.State.normal)
//        buttonConnect.isEnabled = false
//    }
//    @objc func btnGetKey(sender: UIButton) {
//        let data = "Client: OK".data(using: .utf8)!
//        _ = data.withUnsafeBytes {bytes in
//            outStream?.write(bytes, maxLength: data.count)
//        }
//
//        //let data : NSData = "Client: OK".data(using: .utf8) //usingEncoding: NSUTF8StringEncoding)! as NSData
//        //sdata.withUnsafeBytes{_ in outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)}
//        //outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
//    }
//    @objc func btnSendMsg(sender: UIButton) {
//
//        let message = "Secret message from iPhone!!"
//
//        let data = message.data(using: .utf8)//(message as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
//
//        // tag name to access the stored public key in keychain
//        let TAG_PUBLIC_KEY = "com.mycompany.tag_public"
//
//        let encryptStr = "encrypted_message="
//        let encryptStrData = encryptStr.data(using: .utf8)//usingEncoding: NSUTF8StringEncoding)!
//
//        let encryptedData = RSAUtils.encryptWithRSAPublicKey(data!, pubkeyBase64: keyString, keychainTag: TAG_PUBLIC_KEY)!
//
//        let length = encryptStrData!.count + encryptedData.count
//
//        var array = [UInt8](repeating: 0, count: length)//[UInt8](unsafeUninitializedCapacity: length, initializingWith: 0)
//        encryptStrData!.copyBytes(to:&array, count: encryptStrData!.count)//encryptStrData.getBytes(&array, length: encryptStrData.length)
//        encryptedData.copyBytes(to:&array+encryptStrData!.count, count: encryptedData.count)//encryptedData.getBytes(&array+encryptStrData.length, length: encryptedData.length)
//
//        outStream?.write(UnsafePointer<UInt8>(array), maxLength: length)
//
//        deactivateButton(button: buttonSendMsg)
//        buttonSendMsg.isEnabled = false
//        activateButton(button: buttonQuit)
//        buttonQuit.isEnabled = true
//
//        label.text = "Encrypted message sent"
//    }
//    @objc func btnQuitPressed(sender: UIButton) {
//        let data = "Quit".data(using: .utf8)!
//        _ = data.withUnsafeBytes {bytes in
//            outStream?.write(bytes, maxLength: data.count)
//        }
//        //let data : Data = "Quit".data(using: <#String.Encoding#>)! as Data//(usingEncoding: NSUTF8StringEncoding)! as NSData
//        //data.withUnsafeBytes{_ in outStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)}
//
//        deactivateButton(button: buttonQuit)
//        buttonQuit.isEnabled = false
//    }
//
//    //Label setup function
//    func LabelSetup() {
//        label = UILabel(frame: CGRect(x: 0,y: 0,width: 300,height: 150))
//        label.center = CGPoint(x: view.center.x, y: view.center.y+100)
//        label.textAlignment = NSTextAlignment.center
//        label.numberOfLines = 0 //Multi-lines
//        label.font = UIFont(name: "Helvetica-Bold", size: 20)
//        view.addSubview(label)
//
//        labelConnection = UILabel(frame: CGRect(x: 0,y: 0,width: 300,height: 30))
//        labelConnection.center = view.center
//        labelConnection.textAlignment = NSTextAlignment.center
//        labelConnection.text = "Please connect to server"
//        view.addSubview(labelConnection)
//    }
//
//    //Network functions
//    func NetworkEnable() {
//
//        //print("NetworkEnable")
//        //print(addr)
//        //print(port)
//        Stream.getStreamsToHost(withName: addr, port: port, inputStream: &inStream, outputStream: &outStream)
//
//        inStream?.delegate = self
//        outStream?.delegate = self
//
//        inStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
//        outStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
//
//        inStream?.open()
//        outStream?.open()
//
//        buffer = [UInt8](repeating: 0, count: 2000)//[UInt8](unsafeUninitializedCapacity: 2000, initializingWith: 0)
//    }
//
//    //func stream(aStream: Stream, handleEvent eventCode: Stream.Event) {
//    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
//        switch eventCode {
//        case Stream.Event.endEncountered:
//            print("EndEncountered")
//            labelConnection.text = "Connection stopped by server"
//            label.text = ""
//
//            inStream?.close()
//            inStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
//            outStream?.close()
//            print("Stop outStream currentRunLoop")
//            outStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
//            activateButton(button: buttonConnect)
//
//            buttonConnect.setTitle("Connect", for: UIControl.State.normal)
//            buttonConnect.isEnabled = true
//            buffer.removeAll(keepingCapacity: true)
//            keyString = ""
//        case Stream.Event.errorOccurred:
//            print("ErrorOccurred")
//
//            inStream?.close()
//            inStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
//            outStream?.close()
//            outStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
//            labelConnection.text = "Failed to connect to server"
//            activateButton(button: buttonConnect)
//            buttonConnect.setTitle("Connect", for: UIControl.State.normal)
//            buttonConnect.isEnabled = true
//            label.text = ""
//        case Stream.Event.hasBytesAvailable:
//            print("HasBytesAvailable")
//
//            if aStream == inStream {
//
//                inStreamLength = inStream!.read(&buffer, maxLength: buffer.count)
//
//                let bufferStr = NSString(bytes: &buffer, length: inStreamLength, encoding: String.Encoding.utf8.rawValue)! as String
//
//                if keyString == "" {
//                    label.text = "Public key received"
//                    keyString = getKeyStringFromPEMString(PEMString: bufferStr)
//                    deactivateButton(button: buttonGetKey)
//                    buttonGetKey.isEnabled = false
//
//                    activateButton(button: buttonSendMsg)
//                    buttonSendMsg.isEnabled = true
//                }
//                else {
//                    print(bufferStr)
//                }
//
//            }
//
//        case Stream.Event.hasSpaceAvailable:
//            print("HasSpaceAvailable")
//        //case Stream.Event.None:
//        //    print("None")
//        case Stream.Event.openCompleted:
//            print("OpenCompleted")
//            labelConnection.text = "Connected to server"
//            activateButton(button: buttonGetKey)
//            buttonGetKey.isEnabled = true
//
//            //Custom Deactivate Button
//            buttonConnect.layer.cornerRadius = 5
//            buttonConnect.backgroundColor = UIColor.systemGray
//            buttonConnect.setTitle("Connected", for: UIControl.State.normal)
//        default:
//            print("Unknown")
//        }
//    }
//
//    //Key function - remove header and footer
//    func getKeyStringFromPEMString(PEMString: String) -> String {
//
//        let keyArray = PEMString.components(separatedBy: "\n")//.componentsSeparatedByString("\n") //Remove new line characters
//
//        var keyOutput : String = ""
//
//        for item in keyArray {
//            if !item.contains("-----") { //Example: -----BEGIN PUBLIC KEY-----
//                keyOutput += item //Join the text together as a single string
//            }
//        }
//        return keyOutput
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//}
