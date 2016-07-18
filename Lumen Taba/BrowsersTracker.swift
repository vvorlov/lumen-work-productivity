//
//  BrowsersTracker.swift
//  Lumen Taba
//
//  Created by Vladislav Orlov on 07.07.16.
//  Copyright © 2016 Vladislav Orlov. All rights reserved.
//

import Foundation

class BrowsersTracker: NSObject {
    
    //time interval for check browsers tabs
    private let CHECK_INTERVAL: UInt32 = 1
    
    //file with script
    private let scriptFileName: String!
    
    //text of script
    private var scriptText: String?
    
    //if was bad url
    private var lastBadUrl: String?
    
    //Url validator
    private let urlValidator: UrlValidator!
    
    private var needStop: Bool
    private var isRunning: Bool
    
    
    init(scriptName: String, badUrlsPath: String) {
        scriptFileName = scriptName
        
        urlValidator = UrlValidator(badRegexesPath: badUrlsPath)
        
        needStop = false
        isRunning = false
    }
    
    func isValid() -> Bool {
        scriptText = getScript()
        
        //if filename is not valid
        if (scriptText == nil) {
            return false
        }
        
        return true
    }
    
    func start() {
        if (!isValid()) {
            print("It's not valid")
            return
        }
        
        if isRunning {
            return
        }
        
        needStop = false
        
        //run tracker in background mode
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            while !self.needStop {
                self.isRunning = true
                var error: NSDictionary?
                
                //run script
                if let scriptObject = NSAppleScript(source: self.scriptText!) {
                    if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                        &error) {
                        //if browser is active
                        if output.stringValue != nil {
                            
                            //this app is active
                            if (output.int32Value == 1) {
                                continue
                            }
                            
                            //if bad url
                            if self.urlValidator.isUrlStringBanned(output.stringValue!) {
                                
                                //bad url isn't changed
                                if self.lastBadUrl == output.stringValue {
                                    continue
                                }
                                
                                self.lastBadUrl = output.stringValue
                                NSNotificationCenter.defaultCenter().postNotificationName("BadUrlIsOpened",
                                    object: self.lastBadUrl)
                                continue
                            }
                            
                        }
                        
                        
                        //the browser is not active
                        //turn off lamp if it was on
                        if self.lastBadUrl != nil {
                            self.lastBadUrl = nil
                            NSNotificationCenter.defaultCenter().postNotificationName("BadUrlIsClosed", object: nil)
                        }

                    } else if (error != nil) {
                        print("error")
                    }
                }
                sleep(self.CHECK_INTERVAL)
            }
            
            self.isRunning = false
        })
    }
    
    func stop() {
        if isRunning {
            needStop = true
        }
    }
    
    
    private func getScript() -> String? {
        let urlpath = NSBundle.mainBundle().pathForResource(scriptFileName, ofType: "script")
        let fileUrl = NSURL.fileURLWithPath(urlpath!)
        var scriptText = ""
        do {
            scriptText = try NSString(contentsOfURL: fileUrl, encoding: NSUTF8StringEncoding) as String
        } catch {
            print("error: no file")
            return nil
        }
        
        return scriptText
    }
}
