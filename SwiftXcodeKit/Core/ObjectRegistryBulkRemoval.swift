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

private func addObjectIdentifiersInDictionary(dict: [String: AnyObject], inout toArray identifiers: [String]) {
    for object in dict.values {
        if object is OID {
            let id = object as! OID
            identifiers.append(id.key)
        } else if object is [String: AnyObject] {
            addObjectIdentifiersInDictionary(object as! [String: AnyObject], toArray: &identifiers)
        } else if object is [AnyObject] {
            addObjectIdentifiersInArray(object as! [AnyObject], toArray: &identifiers)
        }
    }
}

private func addObjectIdentifiersInArray(array: [AnyObject], inout toArray identifiers: [String]) {
    for object in array {
        if object is OID {
            let id = object as! OID
            identifiers.append(id.key)
        } else if object is [String: AnyObject] {
            addObjectIdentifiersInDictionary(object as! [String: AnyObject], toArray: &identifiers)
        } else if object is [AnyObject] {
            addObjectIdentifiersInArray(object as! [AnyObject], toArray: &identifiers)
        }
    }
}

extension ObjectRegistry {
    public func removeUnreferencedResources() {
        var referencedObjectIdentifiers = [String]()
        addObjectIdentifiersInDictionary(objectDictionary, toArray: &referencedObjectIdentifiers)
        
        var keysToRemove = [String]()
        for key in objectDictionary.keys {
            if !doesArrayContain(referencedObjectIdentifiers, value: key) {
                keysToRemove.append(key)
            }
        }
        
        var objects = objectDictionary
        for key in keysToRemove {
            objectDictionary.removeValueForKey(key)
        }
    }
}
