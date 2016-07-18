//
//  UrlValidator.swift
//  Lumen Taba
//
//  Created by Vladislav Orlov on 06.07.16.
//  Copyright © 2016 Vladislav Orlov. All rights reserved.
//

import Foundation

class UrlValidator: NSObject {
    
    //file with bad urls
    private let filepath: String!
    
    init(badRegexesPath: String) {
        self.filepath = badRegexesPath
    }
    
    func isUrlStringBanned(urlString: String) -> Bool {
        let url = NSURL(string: urlString)
        
        //check if url is valid
        if (url == nil) {
            return false
        }
        
        return checkUrl(url!)
    }
    
    private func checkUrl(url: NSURL) -> Bool {
        let domain = url.host
        
        //there is no domain
        if (domain == nil) {
            return false
        }
        
        let badRegexes = getBadRegexes()
        for br in badRegexes {
            if matchesForRegexInText(br, text: url.absoluteString) {
                return true
            }
        }
        
        return false
    }

    private func matchesForRegexInText(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                                                options: [],
                                                range: NSMakeRange(0, nsString.length))
            return results.count > 0 ? true : false
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }

    //read from file bad regexes
    private func getBadRegexes() -> [String] {
        var res = [String]()
        
        //read file by line
        let fileUrl = NSURL(fileURLWithPath: filepath)
        var fileText = ""
        do {
            fileText = try NSString(contentsOfURL: fileUrl,
                                    encoding: NSUTF8StringEncoding) as String
        } catch {
            print("File with URLs is not valid")
            return res
        }
        
        res = fileText.componentsSeparatedByString("\n")
        
        return res
    }
    
}
