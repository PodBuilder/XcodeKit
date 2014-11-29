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

public enum PathResolveBase {
    case Group
    case SDK
    case BuiltProductsDirectory
    
    private var PBXString: String {
        get {
            switch self {
            case .Group:
                return "<group>"
            case .SDK:
                return "SDKROOT"
            case .BuiltProductsDirectory:
                return "BUILT_PRODUCTS_DIR"
            }
        }
    }
    
    private static func parsePBXString(str: String) -> PathResolveBase {
        if str == "<group>" {
            return .Group
        } else if str == "SDKROOT" {
            return .SDK
        } else if str == "BUILT_PRODUCTS_DIR" {
            return .BuiltProductsDirectory
        } else {
            fatalError("Unrecognized PBX string")
        }
    }
}

public class FileReference: Resource {
    public override class var isaString: String {
        get {
            return "PBXFileReference"
        }
    }
    
    public class func createFileReferenceForRegularFile(inout inRegistry registry: ObjectRegistry, additionalProperties: [String: AnyObject]) -> FileReference {
        var properties: [String: AnyObject] = [ "isa": isaString, "sourceTree": PathResolveBase.Group.PBXString ]
        properties.merge(additionalProperties)
        
        let reference = FileReference(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(reference)
        return reference
    }
    
    public class func createFileReferenceForFramework(name: String, path: String, inout inRegistry registry: ObjectRegistry, additionalProperties: [String: AnyObject]) -> FileReference {
        var properties: [String: AnyObject] = [ "isa": isaString, "lastKnownFileType": "wrapper.framework", "sourceTree": PathResolveBase.Group.PBXString ]
        properties.merge(additionalProperties)
        properties["name"] = name.pathExtension == "framework" ? name.stringByDeletingPathExtension : name
        properties["path"] = path
        
        let reference = FileReference(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(reference)
        return reference
    }
    
    public class func createFileReferenceForSDKFramework(name: String, inout inRegistry registry: ObjectRegistry, additionalProperties: [String: AnyObject]) -> FileReference {
        var properties: [String: AnyObject] = [ "isa": isaString, "lastKnownFileType": "wrapper.framework", "sourceTree": PathResolveBase.SDK.PBXString ]
        properties.merge(additionalProperties)
        properties["name"] = name.pathExtension == "framework" ? name.stringByDeletingPathExtension : name
        properties["path"] = "System/Library/Frameworks/\(name).framework"
        
        let reference = FileReference(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(reference)
        return reference
    }
    
    public class func createFileReferenceForSDKLibrary(name: String, inout inRegistry registry: ObjectRegistry, additionalProperties: [String: AnyObject]) -> FileReference {
        var properties: [String: AnyObject] = [ "isa": isaString, "lastKnownFileType": "compiled.mach-o.dylib", "sourceTree": PathResolveBase.Group.PBXString ]
        properties.merge(additionalProperties)
        properties["name"] = name.pathExtension == "framework" ? name.stringByDeletingPathExtension : name
        properties["path"] = "usr/lib/\(name)"
        
        let reference = FileReference(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(reference)
        return reference
    }
    
    public class func createFileReferenceForApplicationProduct(name: String, inout inRegistry registry: ObjectRegistry, additionalProperties: [String: AnyObject]) -> FileReference {
        var properties: [String: AnyObject] = [ "isa": isaString, "lastKnownFileType": "wrapper.application", "sourceTree": PathResolveBase.BuiltProductsDirectory.PBXString, "includeInIndex": "0" ]
        properties.merge(additionalProperties)
        properties["name"] = name.pathExtension == "framework" ? name.stringByDeletingPathExtension : name
        properties["path"] = "\(name).app"
        
        let reference = FileReference(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(reference)
        return reference
    }
    
    public var parentGroup: Group?
    
    public var name: String {
        get {
            let value: AnyObject? = properties["name"]
            return value! as String
        }
        
        set {
            properties["name"] = newValue
            save()
        }
    }
    
    public var path: String {
        get {
            let value: AnyObject? = properties["path"]
            return value! as String
        }
        
        set {
            properties["path"] = newValue
            save()
        }
    }
    
    public var resolveBase: PathResolveBase {
        get {
            let value: AnyObject? = properties["sourceTree"]
            return PathResolveBase.parsePBXString(value! as String)
        }
        
        set {
            properties["sourceTree"] = newValue.PBXString
            save()
        }
    }
    
    public var explicitFileType: String? {
        get {
            let value: AnyObject? = properties["explicitFileType"]
            return value as? String
        }
        
        set {
            properties["explicitFileType"] = newValue
            save()
        }
    }
    
    public var lastKnownFileType: String?
    public var includeInIndex: Bool {
        get {
            let rawValue: AnyObject? = properties["includeInIndex"]
            if rawValue == nil {
                // This property defaults to true if it is not specified.
                return true
            }
            
            let possibleValue: AnyObject = rawValue!
            if let value = rawValue as? String {
                if value == "1" {
                    return true
                } else if value == "0" {
                    return false
                }
            }
            
            fatalError("Unrecognized includeInIndex value")
        }
        
        set {
            properties["includeInIndex"] = newValue ? "1" : "0"
            save()
        }
    }
    
    public func removeFromParentGroup() {
        parentGroup?.removeChild(self)
    }
}
