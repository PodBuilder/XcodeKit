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

/*
 * The contents of the CopyFilesDestination enum were borrowed from the CocoaPods Xcodeproj library.
 *
 * Copyright (c) 2012 Eloy Durán <eloy.de.enige@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

public enum CopyFilesDestination {
    case AbsolutePath
    case ProductsDirectory
    case Wrapper
    case ResourcesDirectory
    case Executables
    case JavaResources
    case Frameworks
    case SharedFrameworks
    case SharedSupport
    case PlugIns
    
    private var PBXDestinationNumber: Int {
        get {
            switch self {
            case .AbsolutePath:
                return 0
            case .ProductsDirectory:
                return 16
            case .Wrapper:
                return 1
            case .ResourcesDirectory:
                return 7
            case .Executables:
                return 6
            case .JavaResources:
                return 15
            case .Frameworks:
                return 10
            case .SharedFrameworks:
                return 11
            case .SharedSupport:
                return 12
            case .PlugIns:
                return 13
            }
        }
    }
    
    private static func fromPBXDestinationNumber(number: Int) -> CopyFilesDestination {
        if number == 0 {
            return .AbsolutePath
        } else if number == 16 {
            return .ProductsDirectory
        } else if number == 1 {
            return .Wrapper
        } else if number == 7 {
            return .ResourcesDirectory
        } else if number == 6 {
            return .Executables
        } else if number == 15 {
            return .JavaResources
        } else if number == 10 {
            return .Frameworks
        } else if number == 11 {
            return .SharedFrameworks
        } else if number == 12 {
            return .SharedSupport
        } else if number == 13 {
            return .PlugIns
        } else {
            fatalError("Unrecognized CopyFilesDestination PBX number")
        }
    }
}

public class CopyFilesBuildPhase: BuildPhase {
    public override class var isaString: String {
        get {
            return "PBXCopyFilesBuildPhase"
        }
    }
    
    public class func createWithDestination(dest: CopyFilesDestination, inout inRegistry registry: ObjectRegistry) -> CopyFilesBuildPhase {
        return createWithDestination(dest, destinationSubdirectory: "", inRegistry: &registry)
    }
    
    public class func createWithDestination(dest: CopyFilesDestination, destinationSubdirectory subdir: String, inout inRegistry registry: ObjectRegistry) -> CopyFilesBuildPhase {
        let properties = [
            "isa": isaString,
            "buildActionMask": NSNumber(integer: 8),
            "files": [AnyObject](),
            "runOnlyForDeploymentPreprocessing": "0",
            "dstSubfolderSpec": NSNumber(integer: dest.PBXDestinationNumber),
            "dstPath": subdir
        ]
        
        let phase = CopyFilesBuildPhase(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(phase)
        return phase
    }
    
    public var copyOnlyWhenInstalling: Bool {
        get {
            if let valueObject: AnyObject = properties["runOnlyForDeploymentPreprocessing"] {
                if let value = valueObject as? String {
                    if value == "1" {
                        return true
                    } else if value == "0" {
                        return false
                    }
                }
            }
            
            return false
        }
        
        set {
            properties["runOnlyForDeploymentPreprocessing"] = newValue ? "1" : "0"
            save()
        }
    }
    
    public var destination: CopyFilesDestination? {
        get {
            if let valueObject: AnyObject = properties["dstSubfolderSpec"] {
                if let value = valueObject as? NSNumber {
                    return CopyFilesDestination.fromPBXDestinationNumber(value.integerValue)
                }
            }
            
            return nil
        }
        
        set {
            if let destination = newValue {
                properties["dstSubfolderSpec"] = NSNumber(integer: destination.PBXDestinationNumber)
            } else {
                properties.removeValueForKey("dstSubfolderSpec")
            }
            
            save()
        }
    }
    
    public var destinationSubdirectory: String {
        get {
            if let valueObject: AnyObject = properties["dstPath"] {
                if let value = valueObject as? String {
                    return value
                }
            }
            
            return ""
        }
        
        set {
            properties["dstPath"] = newValue
            save()
        }
    }
    
    public var name: String? {
        get {
            if let valueObject: AnyObject = properties["name"] {
                if let value = valueObject as? String {
                    return value
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
}
