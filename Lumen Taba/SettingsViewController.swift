//
//  SettingsViewController.swift
//  Lumen Taba
//
//  Created by Vladislav Orlov on 08.07.16.
//  Copyright © 2016 Vladislav Orlov. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    var fileUrl: NSURL!
    
    @IBOutlet var textEditorView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let badUrlsPath = NSBundle.mainBundle().pathForResource("domains", ofType: "list")
        fileUrl = NSURL(fileURLWithPath: badUrlsPath!)
    }
    
    override func viewWillAppear() {
        textEditorView.string = readStringDataFromFile()
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if (textEditorView.string != nil) {
            writeStringDataToFile(textEditorView.string!)
        }
    }
    
    private func readStringDataFromFile() -> String {
        do {
            return try NSString(contentsOfURL: fileUrl,
                                    encoding: NSUTF8StringEncoding) as String
        } catch {
            return ""
        }
    }
    
    private func writeStringDataToFile(data: String) {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            do {
                try data.writeToURL(self.fileUrl, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
        })
        
        self.view.window?.close()
    }
    
}
