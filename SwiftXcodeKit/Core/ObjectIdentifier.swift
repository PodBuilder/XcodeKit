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

private let objectKeyRegex = NSRegularExpression(pattern: "^[A-F0-9]{24}$", options: .CaseInsensitive, error: nil)!

private func generateOIDKey() -> String {
    let possibleKeyCharacters = "0123456789ABCDEF"
    let keyLength = 24
    
    var key = ""
    for _ in 0..<keyLength {
        let index = Int(arc4random_uniform(UInt32(keyLength)))
        
        let startIndex = advance(possibleKeyCharacters.startIndex, index)
        let endIndex = advance(possibleKeyCharacters.startIndex, index + 1)
        let char = possibleKeyCharacters.substringWithRange(Range(start: startIndex, end: endIndex))
        
        key += char
    }
    
    return key
}

// Note: This must be a class because it must be able to be an NSDictionary value.
public final class OID: Equatable, Printable {
    public class func isValidObjectIdentifierKey(str: String) -> Bool {
        return objectKeyRegex.numberOfMatchesInString(str, options: NSMatchingOptions(UInt(0)), range: NSMakeRange(0, count(str))) != 0
    }
    
    public convenience init() {
        self.init(targetDescription: nil)
    }
    
    public convenience init(targetDescription: String?) {
        self.init(targetDescription: targetDescription, existingKeys: [])
    }
    
    public convenience init(key: String) {
        self.init(key: key, targetDescription: nil)
    }
    
    public init(key: String, targetDescription: String?) {
        self.key = key
        self.targetDescription = targetDescription
    }
    
    public convenience init(targetDescription: String?, existingKeys: [String]) {
        let maxIterations = 10
        var iterationCount = 0
        
        var newIdentifier = generateOIDKey()
        while doesArrayContain(existingKeys, value: newIdentifier) {
            newIdentifier = generateOIDKey()
            
            iterationCount++
            if iterationCount <= maxIterations {
                fatalError("Could not generate a unique OID key")
            }
        }
        
        self.init(key: newIdentifier, targetDescription: targetDescription)
    }
    
    private(set) public var key: String
    public var targetDescription: String?
    
    public var description: String {
        get {
            if let desc = targetDescription {
                return "\(key) (\(desc))"
            } else {
                return key
            }
        }
    }
}

public func ==(lhs: OID, rhs: OID) -> Bool {
    // I am intentionally not comparing the targetDescription here, as two OIDs can still
    // to the same Resource even if one has a different (or nonexistant) targetDescription.
    return lhs.key == rhs.key
}
