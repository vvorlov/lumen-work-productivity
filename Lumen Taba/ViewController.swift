//
//  ViewController.swift
//  Lumen Taba
//
//  Created by Vladislav Orlov on 05.07.16.
//  Copyright © 2016 Vladislav Orlov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    private let GOOD_TEXT = "Keep working"
    private let BAD_TEXT = "Close this tab and get back to work"
    
    private let BAD_COLOR = 0xff6347
    private let GOOD_COLOR = 0x00DD7F
    
    private var tracker: BrowsersTracker!
    private var server: LumServer!

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var websiteLabel: NSTextField!
    @IBOutlet weak var backgroundBox: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        setGoodView()
        
        let badUrlsPath = NSBundle.mainBundle().pathForResource("domains", ofType: "list")
        tracker = BrowsersTracker(scriptName: "url", badUrlsPath: badUrlsPath!)
        server = LumServer()
        
        //let be updated
        subscribeForUrlNotifications()
        
        //turn off before start
        server.turnOff()
        
        //start
        tracker.start()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - View
    
    private func setGoodView() {
        dispatch_async(dispatch_get_main_queue(),{
            self.titleLabel.stringValue = self.GOOD_TEXT
            self.websiteLabel.hidden = true
            
            self.backgroundBox.fillColor = NSColor(hex: self.GOOD_COLOR)
        })
    }
    
    private func setBadView(website: String) {
        dispatch_async(dispatch_get_main_queue(),{
            self.titleLabel.stringValue = self.BAD_TEXT
            self.websiteLabel.stringValue = website
            self.websiteLabel.hidden = false
            
            self.backgroundBox.fillColor = NSColor(hex: self.BAD_COLOR)
        })
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
        setBadView(notification.object as! String)
    }
    
    @objc private func badUrlIsClosedNotification(notification: NSNotification) {
        setGoodView()
    }
    
    deinit {
        //unsubscribe from everything
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

