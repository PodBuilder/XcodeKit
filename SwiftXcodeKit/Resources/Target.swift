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

public class Target: Resource {
    // Note: Target does not define isaString because it actually has several.
    
    public class func createApplicationTargetWithName(name: String, inout inRegistry registry: ObjectRegistry) -> Target {
        let configList = ConfigurationList.create(inRegistry: &registry)
        configList.resourceDescription = "Build configuration list for PBXNativeTarget \"\(name)\""
        registry.putResource(configList)
        
        let properties: [String: AnyObject] = [
            "isa": "PBXNativeTarget",
            "buildPhases": [AnyObject](),
            "buildRules": [AnyObject](),
            "dependencies": [AnyObject](),
            "productType": "com.apple.product-type.application",
            "buildConfigurationList": configList.identifier,
            "productName": name,
            "name": name
        ]
        
        let targ = Target(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(targ)
        return targ
    }
    
    public class func createAggregateTargetWithName(name: String, inout inRegistry registry: ObjectRegistry) -> Target {
        let configList = ConfigurationList.create(inRegistry: &registry)
        configList.resourceDescription = "Build configuration list for PBXAggregateTarget \"\(name)\""
        registry.putResource(configList)
        
        let properties: [String: AnyObject] = [
            "isa": "PBXAggregateTarget",
            "buildRules": [AnyObject](),
            "dependencies": [AnyObject](),
            "buildConfigurationList": configList.identifier,
            "productName": name,
            "name": name
        ]
        
        let targ = Target(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(targ)
        return targ
    }
    
    public var name: String? {
        get {
            if let nameObject: AnyObject = properties["name"] {
                if let name = nameObject as? String {
                    return name
                }
            }
            
            return nil
        }
        
        set {
            if let name = newValue {
                properties["name"] = name
            } else {
                properties.removeValueForKey("name")
            }
            
            save()
        }
    }
    
    public var productName: String? {
        get {
            if let nameObject: AnyObject = properties["productName"] {
                if let name = nameObject as? String {
                    return name
                }
            }
            
            return nil
        }
        
        set {
            if let name = newValue {
                properties["productName"] = name
            } else {
                properties.removeValueForKey("productName")
            }
            
            save()
        }
    }
    
    public var productReference: FileReference? {
        get {
            if let idObject: AnyObject = properties["productReference"] {
                if let id = idObject as? String {
                    return registry.findObject(identifier: OID(key: id))
                } else if let id = idObject as? OID {
                    return registry.findObject(identifier: id)
                }
            }
            
            return nil
        }
        
        set {
            if let reference = newValue {
                registry.putResource(reference)
                properties["productReference"] = reference.identifier
            } else {
                properties.removeValueForKey("productReference")
            }
            
            save()
        }
    }
    
    public var configurationList: ConfigurationList? {
        get {
            if let idObject: AnyObject = properties["buildConfigurationList"] {
                if let id = idObject as? String {
                    return registry.findObject(identifier: OID(key: id))
                } else if let id = idObject as? OID {
                    return registry.findObject(identifier: id)
                }
            }
            
            return nil
        }
    }
    
    public var buildDependencies: [TargetDependency]? {
        get {
            if let arrayObject: AnyObject = properties["dependencies"] {
                if let array = arrayObject as? [AnyObject] {
                    var retval: [TargetDependency] = []
                    
                    for item in array {
                        if let id = item as? String {
                            if let dependency: TargetDependency = registry.findObject(identifier: OID(key: id)) {
                                retval.append(dependency)
                            }
                        } else if let id = item as? OID {
                            if let dependency: TargetDependency = registry.findObject(identifier: id) {
                                retval.append(dependency)
                            }
                        }
                    }
                    
                    return retval
                }
            }
            
            return nil
        }
    }
    
    public var buildPhases: [BuildPhase]? {
        get {
            if let arrayObject: AnyObject = properties["dependencies"] {
                if let array = arrayObject as? [AnyObject] {
                    var retval: [BuildPhase] = []
                    
                    for item in array {
                        if let id = item as? String {
                            if let phase: BuildPhase = registry.findObject(identifier: OID(key: id)) {
                                retval.append(phase)
                            }
                        } else if let id = item as? OID {
                            if let phase: BuildPhase = registry.findObject(identifier: id) {
                                retval.append(phase)
                            }
                        }
                    }
                    
                    return retval
                }
            }
            
            return nil
        }
    }
    
    public func appendBuildDependency(dependency: TargetDependency) {
        registry.putResource(dependency)
        
        if let arrayObject: AnyObject = properties["dependencies"] {
            if var array = arrayObject as? [AnyObject] {
                array.append(dependency.identifier)
                properties["dependencies"] = array
            }
        }
        
        save()
    }
    
    public func insertBuildDependency(dependency: TargetDependency, atIndex index: Int) {
        registry.putResource(dependency)
        
        if let arrayObject: AnyObject = properties["dependencies"] {
            if var array = arrayObject as? [AnyObject] {
                array.insert(dependency.identifier, atIndex: index)
                properties["dependencies"] = array
            }
        }
        
        save()
    }
    
    public func removeBuildDependency(dependency: TargetDependency) -> Bool {
        // This method returns YES if the build dependency was found and removed
        // or NO if the dependency was not found the buildDependencies array.
        
        if let arrayObject: AnyObject = properties["dependencies"] {
            if var array = arrayObject as? [AnyObject] {
                let newArray = array.filter({
                    (object) -> Bool in
                    if let candidate = object as? TargetDependency {
                        if candidate == dependency {
                            return false
                        }
                    }
                    
                    return true
                })
                
                properties["dependencies"] = newArray
                
                save()
                return true
            }
        }
        
        return false
    }
    
    public func appendBuildPhase(phase: BuildPhase) {
        registry.putResource(phase)
        
        if let arrayObject: AnyObject = properties["buildPhases"] {
            if var array = arrayObject as? [AnyObject] {
                array.append(phase.identifier)
                properties["buildPhases"] = array
            }
        }
        
        save()
    }
    
    public func insertBuildPhase(phase: BuildPhase, atIndex index: Int) {
        registry.putResource(phase)
        
        if let arrayObject: AnyObject = properties["buildPhases"] {
            if var array = arrayObject as? [AnyObject] {
                array.insert(phase.identifier, atIndex: index)
                properties["buildPhases"] = array
            }
        }
        
        save()
    }
    
    public func removeBuildPhase(phase: BuildPhase) -> Bool {
        // This method returns YES if the build phase was found and removed
        // or NO if the dependency was not in the buildDependencies array.
        
        if let arrayObject: AnyObject = properties["buildPhases"] {
            if var array = arrayObject as? [AnyObject] {
                let newArray = array.filter({
                    (object) -> Bool in
                    if let candidate = object as? BuildPhase {
                        if candidate == phase {
                            return false
                        }
                    }
                    
                    return true
                })
                
                properties["buildPhases"] = newArray
                
                save()
                return true
            }
        }
        
        return false
    }
}
