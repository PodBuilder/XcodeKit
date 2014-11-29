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

public class BuildFile: Resource {
    public override class var isaString: String {
        get {
            return "PBXBuildFile"
        }
    }
    
    public class func create(#fileReference: FileReference, buildSettings: [String: AnyObject]?, inout inRegistry registry: ObjectRegistry) -> BuildFile {
        return create(fileReference: fileReference, buildSettings: buildSettings, inRegistry: &registry, additionalProperties: [:])
    }
    
    public class func create(#fileReference: FileReference, buildSettings: [String: AnyObject]?, inout inRegistry registry: ObjectRegistry, additionalProperties: [String: AnyObject]) -> BuildFile {
        var properties: [String: AnyObject] = [:]
        properties["isa"] = isaString
        properties["fileRef"] = fileReference.identifier.key
        if let realSettings = buildSettings {
            properties.merge(realSettings)
        }
        
        let retval = BuildFile(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(retval)
        return retval
    }
    
    public var fileReference: FileReference? {
        get {
            if let idObject: AnyObject = properties["fileRef"] {
                if let id = idObject as? String {
                    if let rsrc: FileReference = registry.findObject(identifier: OID(key: id)) {
                        return rsrc
                    }
                }
            }
            
            return nil
        }
        
        set {
            if let reference = newValue {
                registry.putResource(reference)
                properties["fileRef"] = reference.identifier.key
            } else {
                properties.removeValueForKey("fileRef")
            }
            
            save()
        }
    }
    
    public var buildSettings: [String: AnyObject]? {
        get {
            if let settingsObject: AnyObject = properties["buildSettings"] {
                if let settings = settingsObject as? [String: AnyObject] {
                    return settings
                }
            }
            
            return nil
        }
        
        set {
            if let settings = newValue {
                properties["buildSettings"] = settings
            } else {
                properties.removeValueForKey("buildSettings")
            }
            
            save()
        }
    }
}
