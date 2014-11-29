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

public class Resource: Equatable {
    public class var isaString: String {
        get {
            fatalError("Subclasses of Resource must override isaString")
        }
    }
    
    public convenience init(identifier: OID, inRegistry registry: ObjectRegistry) {
        self.init(identifier: identifier, inRegistry: registry, properties: [:])
    }
    
    public init(identifier: OID, inRegistry registry: ObjectRegistry, properties: [String: AnyObject]) {
        self.identifier = identifier
        self.registry = registry
        self.properties = properties
    }
    
    internal(set) public var registry: ObjectRegistry
    internal(set) public var identifier: OID
    internal(set) public var properties: [String: AnyObject]
    public var resourceDescription: String?
    
    public func save() {
        registry.putResource(self)
    }
}

public func ==(lhs: Resource, rhs: Resource) -> Bool {
    let registriesEqual = lhs.registry == rhs.registry
    let identifiersEqual = lhs.identifier == rhs.identifier
    let propertiesEqual = lhs.properties == rhs.properties
    
    return registriesEqual && identifiersEqual && propertiesEqual
}
