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

private typealias CreateResourceFunction = (OID, ObjectRegistry, [String: AnyObject]) -> Resource
private let resourceIsaTable: [String: CreateResourceFunction] = [
    "PBXProject": { return Project(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXFileReference": { return FileReference(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXGroup": { return Group(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXVariantGroup": { return VariantGroup(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXBuildFile": { return BuildFile(identifier: $0, inRegistry: $1, properties: $2) },
    "XCBuildConfiguration": { return Configuration(identifier: $0, inRegistry: $1, properties: $2) },
    "XCConfigurationList": { return ConfigurationList(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXNativeTarget": { return Target(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXAggregateTarget": { return Target(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXContainerItemProxy": { return ContainerItemProxy(identifier: $0, inRegistry: $1, properties: $2) },
    "PBXTargetDependency": { return TargetDependency(identifier: $0, inRegistry: $1, properties: $2) },
]

public class ObjectRegistry: Equatable {
    public convenience init() {
        self.init(projectPropertyList: [ "formatVersion": NSNumber(integer: 1), "classes": [String: AnyObject](), "objectVersion": NSNumber(integer: 46), "objects": [String: AnyObject]() ])
    }
    
    public init(projectPropertyList dict: [String: AnyObject]) {
        projectPropertyList = dict
    }
    
    private(set) public var projectPropertyList: [String: AnyObject]
    
    public var objectVersion: Int {
        get {
            if let valueObject: AnyObject = projectPropertyList["objectVersion"] {
                if let number = valueObject as? NSNumber {
                    return number.integerValue
                }
            }
            
            return 46
        }
        
        set {
            projectPropertyList["objectVersion"] = NSNumber(integer: newValue)
        }
    }
    
    public var project: Project {
        get {
            let idString: AnyObject? = projectPropertyList["rootObject"]
            let id = OID(key: idString as String, targetDescription: "Project object")
            return findObject(identifier: id)!
        }
        
        set {
            putResource(newValue)
            projectPropertyList["rootObject"] = newValue.identifier
        }
    }
    
    public var objectDictionary: [String: AnyObject] {
        get {
            let value: AnyObject? = projectPropertyList["objects"]
            return value as [String: AnyObject]
        }
        
        set {
            projectPropertyList["objects"] = newValue
        }
    }
    
    public func findObject<ResourceType: Resource>(#identifier: OID) -> ResourceType? {
        // This method returns nil if the OID doesn't exist in the registry, or if there is a type mismatch.
        // A type mismatch can occur if the Resource.isaString doesn't match the isa in the properties dictionary.
        
        let possibleValue: AnyObject? = objectDictionary[identifier.key]
        if let value: AnyObject = possibleValue {
            if let dict = value as? [String: AnyObject] {
                let possibleIsa: AnyObject? = dict["isa"]
                if let isa: AnyObject = possibleIsa {
                    if let isaString = isa as? String {
                        if isaString == ResourceType.isaString {
                            return ResourceType(identifier: identifier, inRegistry: self, properties: dict)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    public func findObject(#identifier: OID) -> Resource? {
        let possibleValue: AnyObject? = objectDictionary[identifier.key]
        if let value: AnyObject = possibleValue {
            if let dict = value as? [String: AnyObject] {
                let possibleIsa: AnyObject? = dict["isa"]
                if let isa: AnyObject = possibleIsa {
                    if let isaString = isa as? String {
                        if let callback = resourceIsaTable[isaString] {
                            return callback(identifier, self, dict)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    public func putResource(resource: Resource) {
        objectDictionary.updateValue(resource.properties, forKey: resource.identifier.key)
    }
    
    public func removeResource(resource: Resource) {
        removeResource(identifier: resource.identifier)
    }
    
    public func removeResource(#identifier: OID) {
        objectDictionary.removeValueForKey(identifier.key)
    }
    
    public func generateOID(#targetDescription: String?) -> OID {
        return OID(targetDescription: targetDescription, existingKeys: objectDictionary.keys.array)
    }
    
    public class func parsePBXProjectText(source: String) -> ObjectRegistry? {
        // This method returns nil if there was a syntax error in the pbxproj text
        let (rootDictionary, error) = parsePBXProjectSource(source)
        if let realDictionary = rootDictionary {
            return ObjectRegistry(projectPropertyList: realDictionary)
        } else {
            return nil
        }
    }
    
    public class func createEmptyProjectWithName(name: String) -> ObjectRegistry {
        var registry = ObjectRegistry()
        
        let mainGroup = Group.createLogicalGroup(name: name, inRegistry: &registry)
        let project = Project.createWithMainGroup(mainGroup, inRegistry: &registry)
        
        registry.project = project
        return registry
    }
}

public func ==(lhs: ObjectRegistry, rhs: ObjectRegistry) -> Bool {
    let leftPlist: NSDictionary = lhs.projectPropertyList
    let rightPlist: NSDictionary = rhs.projectPropertyList
    
    return leftPlist == rightPlist
}
