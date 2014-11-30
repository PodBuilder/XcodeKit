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

public class ContainerItemProxy: Resource {
    public override class var isaString: String {
        get {
            return "PBXContainerItemProxy"
        }
    }
    
    public class func createContainerItemProxyWithProjectIdentifier(target: Target, targetName: String, inout inRegistry registry: ObjectRegistry) -> ContainerItemProxy {
        return createContainerItemProxyWithProjectIdentifier(registry.project.identifier, targetIdentifier: target.identifier, targetName: targetName, inRegistry: &registry)
    }
    
    public class func createContainerItemProxyWithProjectIdentifier(projectId: OID, targetIdentifier: OID, targetName: String, inout inRegistry registry: ObjectRegistry) -> ContainerItemProxy {
        let properties: [String: AnyObject] = [
            "isa": isaString,
            "proxyType": "1",
            "containerPortal": projectId,
            "remoteGlobalIDString": targetIdentifier,
            "remoteInfo": targetName
        ]
        
        let proxy = ContainerItemProxy(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(proxy)
        return proxy
    }
    
    // This is the OID of the project reference containing the target that this item proxy points to.
    // It isn't resolved into a FileReference or Project instance because it could be either.
    public var projectIdentifier: OID? {
        get {
            if let idObject: AnyObject = properties["containerPortal"] {
                if let id = idObject as? OID {
                    return id
                } else if let id = idObject as? String {
                    return OID(key: id)
                }
            }
            
            return nil
        }
        
        set {
            if let id = newValue {
                properties["containerPortal"] = id
            } else {
                properties.removeValueForKey("containerPortal")
            }
        }
    }
    
    // The OID of the target this item proxy points to. This isn't resolved into an instance of
    // Target because the identifier may belong to another registry (different than the one
    /// that owns the receiver).
    public var targetIdentifier: OID? {
        get {
            if let idObject: AnyObject = properties["remoteGlobalIDString"] {
                if let id = idObject as? OID {
                    return id
                } else if let id = idObject as? String {
                    return OID(key: id)
                }
            }
            
            return nil
        }
        
        set {
            if let id = newValue {
                properties["remoteGlobalIDString"] = id
            } else {
                properties.removeValueForKey("remoteGlobalIDString")
            }
        }
    }
    
    public var targetName: String? {
        get {
            if let idObject: AnyObject = properties["name"] {
                if let id = idObject as? String {
                    return id
                }
            }
            
            return nil
        }
        
        set {
            if let id = newValue {
                properties["name"] = id
            } else {
                properties.removeValueForKey("name")
            }
        }
    }
}

public class TargetDependency: Resource {
    public override class var isaString: String {
        get {
            return "PBXTargetDependency"
        }
    }
    
    public class func createWithTarget(target: Target, targetProxy: ContainerItemProxy, inout inRegistry registry: ObjectRegistry) -> TargetDependency {
        let properties: [String: AnyObject] = [
            "isa": isaString,
            "target": target.identifier,
            "targetProxy": targetProxy.identifier
        ]
        
        let dependency = TargetDependency(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(dependency)
        return dependency
    }
    
    public var target: Target? {
        get {
            if let idObject: AnyObject = properties["target"] {
                if let id = idObject as? OID {
                    return registry.findObject(identifier: id)
                } else if let id = idObject as? String {
                    return registry.findObject(identifier: OID(key: id))
                }
            }
            
            return nil
        }
        
        set {
            if let target = newValue {
                properties["target"] = target.identifier
            } else {
                properties.removeValueForKey("target")
            }
        }
    }
    
    public var targetProxy: ContainerItemProxy? {
        get {
            if let idObject: AnyObject = properties["targetProxy"] {
                if let id = idObject as? OID {
                    return registry.findObject(identifier: id)
                } else if let id = idObject as? String {
                    return registry.findObject(identifier: OID(key: id))
                }
            }
            
            return nil
        }
        
        set {
            if let target = newValue {
                properties["targetProxy"] = target.identifier
            } else {
                properties.removeValueForKey("targetProxy")
            }
        }
    }
}
