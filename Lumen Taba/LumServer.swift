//
//  LumServer.swift
//  Lumen Taba
//
//  Created by Vladislav Orlov on 07.07.16.
//  Copyright © 2016 Vladislav Orlov. All rights reserved.
//

import Foundation
import AppKit

class LumServer: NSObject {
    
    private let SERVER_URL = "http://127.0.0.1:5555/"
    private let COLOR_API = "rgb?"
    private let OFF_API = "off"
    
    override init() {
        super.init()
        
        //subscribe for url notifications
        subscribeForUrlNotifications();
    }
    
    func setRedColor() {
        setColor(NSColor.redColor())
    }
    
    
    func turnOff() {
        let turnOffUrl = NSURL(string: SERVER_URL + OFF_API)!
        
        makeRequest(turnOffUrl)
    }
    
    private func setColor(color: NSColor) {
        let colorUrl = NSURL(string:SERVER_URL + COLOR_API + color.toHexString())!
        
        makeRequest(colorUrl)
    }
    
    private func makeRequest(url: NSURL) {
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            if error != nil {
                print("\(error)")
            } else {
                print("request to \(url) is succeed")
            }
        }
    }
    
    // MARK: - Notifications
    
    private func subscribeForUrlNotifications() {
        //subscribe for open bad url
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(badUrlIsOpenedNotification(_:)),
            name: "BadUrlIsOpened",
            object: nil)
        
        //subscribe for close bad url
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(badUrlIsClosedNotification(_:)),
            name: "BadUrlIsClosed",
            object: nil)
    }
    
    @objc private func badUrlIsOpenedNotification(notification: NSNotification) {
        setRedColor()
    }
    
    @objc private func badUrlIsClosedNotification(notification: NSNotification) {
        turnOff()
    }
    
    deinit {
        //unsubscribe from everything
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
