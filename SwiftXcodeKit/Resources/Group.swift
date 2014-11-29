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

public class Group: Resource {
    public class func createLogicalGroup(#name: String, inout inRegistry registry: ObjectRegistry) -> Group {
        var properties = [String: AnyObject]()
        
        properties["isa"] = isaString
        properties["sourceTree"] = "<group>"
        properties["children"] = [AnyObject]()
        properties["name"] = name
        
        var retval = Group(identifier: registry.generateOID(targetDescription: name), inRegistry: registry, properties: properties)
        retval.resourceDescription = name
        registry.putResource(retval)
        return retval
    }
    
    public var parentGroup: Group?
    
    public var children: [Resource]? {
        get {
            if let childrenObject: AnyObject = properties["children"] {
                if let children = childrenObject as? [OID] {
                    var retval: [Resource] = []
                    
                    for childIdentifier in children {
                        if let rsrc = registry.findObject(identifier: childIdentifier) {
                            retval.append(rsrc)
                        } else {
                            NSLog("\(__FUNCTION__): warning: Could not resolve \(childIdentifier), skipping")
                        }
                    }
                    
                    return retval
                }
            }
            
            return nil
        }
    }
    
    public var childFiles: [Resource]? {
        get {
            if let allChildren = children {
                return allChildren.reject { $0 is Group }
            }
            
            return nil
        }
    }
    
    public var childGroups: [Group]? {
        get {
            if let allChildren = children {
                let filtered: [Group?] = allChildren.map {
                    value in
                    return value as? Group
                }
                
                return filtered.reject { $0 == nil }.map { $0! }
            }
            
            return nil
        }
    }
    
    public func addChildGroup(group: Group) {
        if var childrenObject: AnyObject = properties["children"] {
            if var children = childrenObject as? [OID] {
                children.append(group.identifier)
                registry.putResource(group)
            }
            
            save()
        }
    }
    
    public func addChildFileReference(reference: FileReference) {
        if var childrenObject: AnyObject = properties["children"] {
            if var children = childrenObject as? [OID] {
                children.append(reference.identifier)
                registry.putResource(reference)
            }
            
            save()
        }
    }
    
    public func removeChild(group: Group) {
        if var childrenObject: AnyObject = properties["children"] {
            if var children = childrenObject as? [OID] {
                let newChildren = children.reject { $0 == group.identifier }
                properties["children"] = newChildren
            }
            
            save()
        }
    }
    
    public func removeChild(reference: FileReference) {
        if var childrenObject: AnyObject = properties["children"] {
            if var children = childrenObject as? [OID] {
                let newChildren = children.reject { $0 == reference.identifier }
                properties["children"] = newChildren
            }
            
            save()
        }
    }
    
    public func removeFromParentGroup() {
        if let groups = childGroups {
            for group in groups {
                group.removeFromParentGroup()
            }
        }
        
        if let files = childFiles {
            for file in files {
                if var reference = file as? FileReference {
                    reference.removeFromParentGroup()
                }
            }
        }
        
        if var parent = parentGroup {
            parent.removeChild(self)
        }
        
        save()
    }
}

public class VariantGroup: Group {
    public override class var isaString: String {
        get {
            return "PBXVariantGroup"
        }
    }
}
