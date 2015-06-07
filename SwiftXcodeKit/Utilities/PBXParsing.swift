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

private let wspace = NSCharacterSet.whitespaceAndNewlineCharacterSet()

private func scanPBXProjectString(scanner: NSScanner) -> (String?, NSError?) {
    if scanner.peekString("\"") {
        if !scanner.scanString("\"", intoString: nil) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening quoted-string delimiter" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
        
        var value = ""
        var stop = false
        while !stop {
            var possiblePart: NSString?
            scanner.scanUpToString("\"", intoString: &possiblePart)
            if let part = possiblePart {
                value += part as String
                
                if part.hasSuffix("\\") && scanner.peekString("\"") {
                    var possibleQuote: NSString?
                    scanner.scanString("\"", intoString: &possibleQuote)
                    
                    if let quote = possibleQuote {
                        value += quote as String
                    }
                } else {
                    if !scanner.scanString("\"", intoString: nil) {
                        let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing quoted-string delimiter" ]
                        let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                        return (nil, error)
                    }
                    
                    stop = true
                }
            }
        }
        
        return (value.unescapedString, nil)
    } else {
        var retval: NSString?
        let charset = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._/")
        if !scanner.scanCharactersFromSet(charset, intoString: &retval) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Scan unquoted string" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
        
        if let realString = retval {
            return (realString as String, nil)
        }
        
        let error = NSError(domain: ErrorDomain, code: Errors.unspecifiedInternalError, userInfo: nil)
        return (nil, error)
    }
}

private func scanPBXProjectDictionary(scanner: NSScanner) -> ([String: AnyObject]?, NSError?) {
    var parsedDictionary: [String: AnyObject] = [:]
    var innerError: NSError?
    
    scanner.scanCharactersFromSet(wspace, intoString: nil)
    if !scanner.scanString("{", intoString: nil) {
        let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening brace for dictionary" ]
        let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
        return (nil, error)
    }
    scanner.scanCharactersFromSet(wspace, intoString: nil)
    
    while !scanner.peekString("}") {
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        while scanner.peekString("/*") {
            if !scanner.scanString("/*", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening delimiter for ignored comment in dictionary" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanUpToString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Find closing delimiter for ignored comment in dictionary" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing delimiter for ignored comment in dictionary" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            scanner.scanCharactersFromSet(wspace, intoString: nil)
        }
        
        var key: String? = ""
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        (key, innerError) = scanPBXProjectString(scanner)
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        if key == nil {
            var userInfo: [String: AnyObject] = [ "location": scanner.scanLocation, "operation": "Eat opening brace for dictionary" ]
            if let realError = innerError {
                userInfo[NSUnderlyingErrorKey] = realError
            }
            
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo)
            return (nil, error)
        }
        
        var objectComment: String? = nil
        if scanner.peekString("/*") {
            if !scanner.scanString("/*", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening comment delimiter for annotated dictionary key" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            var scannedComment: NSString? = nil
            if !scanner.scanUpToString("*/", intoString: &scannedComment) {
                if let realComment = scannedComment {
                    objectComment = realComment.stringByTrimmingCharactersInSet(wspace)
                }
            }
            
            scanner.scanCharactersFromSet(wspace, intoString: nil)
            if !scanner.scanString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing comment delimiter for annotated dictionary key" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            scanner.scanCharactersFromSet(wspace, intoString: nil)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        if !scanner.scanString("=", intoString: nil) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Eat equals sign in dictionary" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        var value: AnyObject?
        (value, innerError) = scanPBXProjectValue(scanner)
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        if let realValue: AnyObject = value {
            if let realKey = key {
                parsedDictionary[realKey] = realValue
            }
        } else {
            var userInfo: [String: AnyObject] = [ "location": scanner.scanLocation, "operation": "Scan dictionary value" ]
            if let realError = innerError {
                userInfo[NSUnderlyingErrorKey] = realError
            }
            
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo)
            return (nil, error)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        if !scanner.scanString(";", intoString: nil) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Eat semicolon following dictionary key/value pair" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        while scanner.peekString("/*") {
            if !scanner.scanString("/*", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening comment delimiter for ignored comment in dictionary" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanUpToString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Find closing comment delimiter for ignored comment in dictionary" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing comment delimiter for ignored comment in dictionary" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            scanner.scanCharactersFromSet(wspace, intoString: nil)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
    }
    
    scanner.scanCharactersFromSet(wspace, intoString: nil)
    if !scanner.scanString("}", intoString: nil) {
        let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing brace for dictionary" ]
        let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
        return (nil, error)
    }
    
    return (parsedDictionary, nil)
}

private func scanPBXProjectArray(scanner: NSScanner) -> ([AnyObject]?, NSError?) {
    var parsedArray: [AnyObject] = []
    
    scanner.scanCharactersFromSet(wspace, intoString: nil)
    if !scanner.scanString("(", intoString: nil) {
        let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening parenthesis for array" ]
        let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
        return (nil, error)
    }
    scanner.scanCharactersFromSet(wspace, intoString: nil)
    
    while !scanner.peekString(")") {
        while scanner.peekString("/*") {
            if !scanner.scanString("/*", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening delimiter for ignored comment in array" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanUpToString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Find closing delimiter for ignored comment in array" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing delimiter for ignored comment in array" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            scanner.scanCharactersFromSet(wspace, intoString: nil)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        let (value: AnyObject?, innerError) = scanPBXProjectValue(scanner)
        
        if let realValue: AnyObject = value {
            parsedArray.append(realValue)
        } else {
            var userInfo: [String: AnyObject] = [ "location": scanner.scanLocation, "operation": "Scan array value" ]
            if let realError = innerError {
                userInfo[NSUnderlyingErrorKey] = realError
            }
            
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo)
            return (nil, error)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        let seenComma = scanner.scanString(",", intoString: nil)
        
        // The trailing comma can be omitted only if this is the last element in the array.
        if !seenComma {
            let savedLocation = scanner.scanLocation
            scanner.scanCharactersFromSet(wspace, intoString: nil)
            
            if !scanner.scanString(")", intoString: nil) {
                let userInfo: [String: AnyObject] = [ "location": scanner.scanLocation, "operation": "Value in array must be followed by a comma" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo)
                return (nil, error)
            }
            
            scanner.scanLocation = savedLocation
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        while scanner.peekString("/*") {
            if !scanner.scanString("/*", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening delimiter for ignored comment in array" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanUpToString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Find closing delimiter for ignored comment in array" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            if !scanner.scanString("*/", intoString: nil) {
                let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing delimiter for ignored comment in array" ]
                let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
                return (nil, error)
            }
            
            scanner.scanCharactersFromSet(wspace, intoString: nil)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
    }
    
    scanner.scanCharactersFromSet(wspace, intoString: nil)
    if !scanner.scanString(")", intoString: nil) {
        let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closing parenthesis for array" ]
        let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
        return (nil, error)
    }
    
    return (parsedArray, nil)
}

private func scanPBXProjectObjectIdentifier(scanner: NSScanner) -> (OID?, NSError?) {
    let (key, innerError) = scanPBXProjectString(scanner)
    
    if let realError = innerError {
        let userInfo = [ "location": scanner.scanLocation, "operation": "Scan object identifier key", NSUnderlyingErrorKey: realError ]
        let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo)
        return (nil, error)
    }
    
    var objectComment: String? = nil
    
    scanner.scanCharactersFromSet(wspace, intoString: nil)
    if scanner.peekString("/*") {
        if !scanner.scanString("/*", intoString: nil) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening comment delimiter for object identifier" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        
        var scannedComment: NSString? = nil
        if !scanner.scanUpToString("*/", intoString: &scannedComment) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Scan object identifier description" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
        
        if let realComment = scannedComment {
            objectComment = realComment.stringByTrimmingCharactersInSet(wspace)
        }
        
        scanner.scanCharactersFromSet(wspace, intoString: nil)
        if !scanner.scanString("*/", intoString: nil) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Eat closign comment delimiter for object identifier" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
    }
    
    return (OID(key: key!, targetDescription: objectComment), nil)
}

private func scanPBXProjectValue(scanner: NSScanner) -> (AnyObject?, NSError?) {
    if scanner.peekString("\"") {
        let (val, err) = scanPBXProjectString(scanner)
        return (val, err)
    } else if scanner.peekString("(") {
        let (val, err) = scanPBXProjectArray(scanner)
        return (val, err)
    } else if scanner.peekString("{") {
        let (val, err) = scanPBXProjectDictionary(scanner)
        return (val, err)
    } else {
        let savedLocation = scanner.scanLocation
        let (possibleKey, innerError) = scanPBXProjectString(scanner)
        
        if let realKey = possibleKey {
            if OID.isValidObjectIdentifierKey(realKey) {
                scanner.scanLocation = savedLocation
                let (val, err) = scanPBXProjectObjectIdentifier(scanner)
                return (val, err)
            }
        }
        
        return (possibleKey, innerError)
    }
}

internal func parsePBXProjectSource(text: String) -> ([String: AnyObject]?, NSError?) {
    let scanner = NSScanner(string: text)
    scanner.charactersToBeSkipped = NSCharacterSet(range: NSMakeRange(0, 0))
    
    // Eat the opening encoding comment (if any)
    if scanner.scanString("//", intoString: nil) {
        let newlines = NSCharacterSet.newlineCharacterSet()
        
        if !scanner.scanUpToCharactersFromSet(newlines, intoString: nil) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening comment" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
        
        if !scanner.scanCharactersFromSet(newlines, intoString: nil) {
            let userInfo = [ "location": scanner.scanLocation, "operation": "Eat opening comment trailing newline" ]
            let error = NSError(domain: ErrorDomain, code: Errors.syntaxErrorInPBXProject, userInfo: userInfo as [NSObject : AnyObject])
            return (nil, error)
        }
    }
    
    let (val, err) = scanPBXProjectDictionary(scanner)
    return (val, err)
}
