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

private let safeCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_")
private func escapePBXProjectString(base: String) -> String {
    var needsQuoting = false
    
    let bridgedBase: NSString = base
    let length = count(base)
    for i in 0..<length {
        let char: unichar = bridgedBase.characterAtIndex(i)
        if !safeCharacterSet.characterIsMember(char) {
            needsQuoting = true
            break
        }
    }
    
    if needsQuoting {
        return "\"\(base.escapedString)\""
    } else {
        return base
    }
}

private func generatePBXProjectTextForDictionary(dict: [String: AnyObject], inout inString text: String, indentLevel tabCount: Int) {
    let indent = repeatString("\t", times: tabCount)
    let innerIndent = repeatString("\t", times: tabCount + 1)
    
    text += "{\n";
    
    for key in dict.keys {
        let value: AnyObject = dict[key]!
        
        text += "\(innerIndent)\(escapePBXProjectString(key)) = "
        
        if value is String {
            text += escapePBXProjectString(value as! String)
        } else if value is NSNumber {
            let num = value as! NSNumber
            text += escapePBXProjectString(num.description)
        } else if value is [String: AnyObject] {
            generatePBXProjectTextForDictionary(value as! [String: AnyObject], inString: &text, indentLevel: tabCount + 1)
        } else if value is [AnyObject] {
            generatePBXProjectTextForArray(value as! [AnyObject], inString: &text, indentLevel: tabCount + 1)
        } else if value is OID {
            let id = value as! OID
            
            if let desc = id.targetDescription {
                text += "\(id.key) /* \(desc) */"
            } else {
                text += id.key
            }
        } else {
            fatalError("Unexpected dictionary value type")
        }
        
        text += ";\n"
    }
    
    text += "\(indent)}"
}

private func generatePBXProjectTextForArray(array: [AnyObject], inout inString text: String, indentLevel tabCount: Int) {
    let indent = repeatString("\t", times: tabCount)
    let innerIndent = repeatString("\t", times: tabCount + 1)
    
    text += "(\n";
    
    for value in array {
        text += innerIndent
        
        if value is String {
            text += escapePBXProjectString(value as! String)
        } else if value is NSNumber {
            let num = value as! NSNumber
            text += escapePBXProjectString(num.description)
        } else if value is [String: AnyObject] {
            generatePBXProjectTextForDictionary(value as! [String: AnyObject], inString: &text, indentLevel: tabCount + 1)
        } else if value is [AnyObject] {
            generatePBXProjectTextForArray(value as! [AnyObject], inString: &text, indentLevel: tabCount + 1)
        } else if value is OID {
            let id = value as! OID
            
            if let desc = id.targetDescription {
                text += "\(id.key) /* \(desc) */"
            } else {
                text += id.key
            }
        } else {
            fatalError("Unexpected array value type")
        }
        
        text += ",\n"
    }
    
    text += "\(indent))"
}

extension ObjectRegistry {
    public var xcodePBXProjectText: String {
        get {
            var text = ""
            
            text += "// !$*UTF8*$!\n"
            generatePBXProjectTextForDictionary(projectPropertyList, inString: &text, indentLevel: 0)
            text += "\n"
            
            return text
        }
    }
}
