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

public class Project: Resource {
    public override class var isaString: String {
        get {
            return "PBXProject"
        }
    }
    
    public class func createWithMainGroup(group: Group, inout inRegistry registry: ObjectRegistry) -> Project {
        let productsGroup = Group.createLogicalGroup(name: "Products", inRegistry: &registry)
        group.addChildGroup(productsGroup)
        return createWithMainGroup(group, productReferenceGroup: productsGroup, inRegistry: &registry)
    }
    
    public class func createWithMainGroup(mainGroup: Group, productReferenceGroup: Group, inout inRegistry registry: ObjectRegistry) -> Project {
        let list = ConfigurationList.create(inRegistry: &registry)
        return createWithMainGroup(mainGroup, productReferenceGroup: productReferenceGroup, buildConfigurationList: list, inRegistry: &registry)
    }
    
    public class func createWithMainGroup(mainGroup: Group, productReferenceGroup: Group, buildConfigurationList: ConfigurationList, inout inRegistry registry: ObjectRegistry) -> Project {
        let attributes: [String: AnyObject] = [
            "LastUpgradeCheck": "0600"
        ]
        
        let properties: [String: AnyObject] = [
            "isa": isaString,
            "compatibilityVersion": "Xcode 3.2",
            "developmentRegion": "English",
            "knownRegions": [AnyObject](),
            "hasScannedForEncodings": "0",
            "projectDirPath": "",
            "projectRoot": "",
            "targets": [AnyObject](),
            "attributes": attributes,
            "buildConfigurationList": buildConfigurationList.identifier,
            "mainGroup": mainGroup.identifier,
            "productRefGroup": productReferenceGroup.identifier
        ]
        
        registry.putResource(mainGroup)
        registry.putResource(productReferenceGroup)
        registry.putResource(buildConfigurationList)
        
        let proj = Project(identifier: registry.generateOID(targetDescription: "Project object"), inRegistry: registry, properties: properties)
        registry.putResource(proj)
        return proj
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
        
        set {
            if let list = newValue {
                registry.putResource(list)
                properties["buildConfigurationList"] = list.identifier
            } else {
                properties.removeValueForKey("buildConfigurationList")
            }
            
            save()
        }
    }
    
    public var mainGroup: Group? {
        get {
            if let idObject: AnyObject = properties["mainGroup"] {
                if let id = idObject as? String {
                    return registry.findObject(identifier: OID(key: id))
                } else if let id = idObject as? OID {
                    return registry.findObject(identifier: id)
                }
            }
            
            return nil
        }
        
        set {
            if let group = newValue {
                registry.putResource(group)
                properties["mainGroup"] = group.identifier
            } else {
                properties.removeValueForKey("mainGroup")
            }
            
            save()
        }
    }
    
    public var productReferenceGroup: Group? {
        get {
            if let idObject: AnyObject = properties["productRefGroup"] {
                if let id = idObject as? String {
                    return registry.findObject(identifier: OID(key: id))
                } else if let id = idObject as? OID {
                    return registry.findObject(identifier: id)
                }
            }
            
            return nil
        }
        
        set {
            if let group = newValue {
                registry.putResource(group)
                properties["productRefGroup"] = group.identifier
            } else {
                properties.removeValueForKey("productRefGroup")
            }
            
            save()
        }
    }
    
    public var targets: [Target]? {
        get {
            if let arrayObject: AnyObject = properties["targets"] {
                if let array = arrayObject as? [AnyObject] {
                    var retval: [Target] = []
                    
                    for item in array {
                        if let id = item as? String {
                            if let target: Target = registry.findObject(identifier: OID(key: id)) {
                                retval.append(target)
                            }
                        } else if let id = item as? OID {
                            if let target: Target = registry.findObject(identifier: id) {
                                retval.append(target)
                            }
                        }
                    }
                    
                    return retval
                }
            }
            
            return nil
        }
        
        set {
            if let array = newValue {
                var identifiers: [AnyObject] = []
                
                for target in array {
                    registry.putResource(target)
                    identifiers.append(target.identifier)
                }
                
                properties["targets"] = identifiers
            } else {
                properties.removeValueForKey("targets")
            }
            
            save()
        }
    }
    
    public var attributes: [String: AnyObject]? {
        get {
            if let attrObject: AnyObject = properties["attributes"] {
                if let attrs = attrObject as? [String: AnyObject] {
                    return attrs
                }
            }
            
            return nil
        }
        
        set {
            if let attrs = newValue {
                properties["attributes"] = attrs
            } else {
                properties.removeValueForKey("attributes")
            }
            
            save()
        }
    }
}
