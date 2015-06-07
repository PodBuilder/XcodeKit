/*
 * The sources in the "XcodeKit" directory are based on the Ruby project Xcoder.
 *
 * Copyright (c) 2012 cisimple
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

private var repeatedStringCache = NSCache()
internal func repeatString(base: String, #times: Int) -> String {
    if times == 0 {
        return ""
    }
    
    let cacheKey = "\(times)*\(base)"
    let cacheValue: AnyObject? = repeatedStringCache.objectForKey(cacheKey)
    if let realValue: AnyObject = cacheValue {
        return realValue as! String
    }
    
    var repeated = ""
    for _ in 0..<times {
        repeated += base
    }
    
    repeatedStringCache.setValue(repeated, forKey: cacheKey)
    return repeated
}

internal extension String {
    var escapedString: String {
        get {
            var modified = NSMutableString(string: self)
            let options = NSStringCompareOptions(UInt(0))
            
            modified.replaceOccurrencesOfString("\\", withString: "\\\\", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\"", withString: "\\\"", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\r", withString: "\\r", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\n", withString: "\\n", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\t", withString: "\\t", options: options, range: NSMakeRange(0, modified.length))
            
            return modified as String
        }
    }
    
    var unescapedString: String {
        get {
            var modified = NSMutableString(string: self)
            let options = NSStringCompareOptions(UInt(0))
            
            modified.replaceOccurrencesOfString("\\\\", withString: "\\", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\\\"", withString: "\"", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\\r", withString: "\r", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\\n", withString: "\n", options: options, range: NSMakeRange(0, modified.length))
            modified.replaceOccurrencesOfString("\\t", withString: "\t", options: options, range: NSMakeRange(0, modified.length))
            
            return modified as String
        }
    }
}

internal extension Dictionary {
    mutating func merge(other: Dictionary<Key, Value>) {
        for (key, value) in other {
            self[key] = value
        }
    }
}

internal extension NSScanner {
    func peekString(stringToPeek: String) -> Bool {
        let savedLocation = scanLocation
        let seen = scanString(stringToPeek, intoString: nil)
        scanLocation = savedLocation
        
        return seen
    }
}

internal func ==(lhs: [String: AnyObject], rhs: [String: AnyObject]) -> Bool {
    let lhsCocoa: NSDictionary = lhs
    let rhsCocoa: NSDictionary = rhs
    
    return lhsCocoa == rhsCocoa
}
