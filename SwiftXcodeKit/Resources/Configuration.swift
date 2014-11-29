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

public class Configuration: Resource {
    public override class var isaString: String {
        get {
            return "XCBuildConfiguration"
        }
    }
    
    public class func createWithName(name: String, inout inRegistry registry: ObjectRegistry) -> Configuration {
        let properties: [String: AnyObject] = [
            "isa": isaString,
            "name": name,
            "buildSettings": [String: String]()
        ]
        
        let phase = Configuration(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(phase)
        return phase
    }
    
    public var name: String {
        get {
            if let valueObject: AnyObject = properties["name"] {
                if let value = valueObject as? String {
                    return value
                }
            }
            
            return ""
        }
        
        set {
            properties["name"] = newValue
            save()
        }
    }
    
    public var buildSettings: [String: String] {
        get {
            if let valueObject: AnyObject = properties["buildSettings"] {
                if let value = valueObject as? [String: String] {
                    return value
                }
            }
            
            return [:]
        }
        
        set {
            properties["buildSettings"] = newValue
            save()
        }
    }
}
