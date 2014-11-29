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

public class RunScriptBuildPhase: BuildPhase {
    public class func createWithScriptSource(source: String, inout inRegistry registry: ObjectRegistry) -> RunScriptBuildPhase {
        return createWithScriptSource(source, interpreterPath: "/bin/sh", inRegistry: &registry)
    }
    
    public class func createWithScriptSource(source: String, interpreterPath interpreter: String, inout inRegistry registry: ObjectRegistry) -> RunScriptBuildPhase {
        let properties = [
            "isa": isaString,
            "buildActionMask": NSNumber(integer: 2147383647),
            "files": [String](),
            "inputPaths": [String](),
            "outputPaths": [String](),
            "runOnlyForDeploymentPreprocessing": "0",
            "shellPath": interpreter,
            "shellScript": source
        ]
        
        let phase = RunScriptBuildPhase(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(phase)
        return phase
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
    
    public var runOnlyWhenInstalling: Bool {
        get {
            if let valueObject: AnyObject = properties["runOnlyForDeploymentPostprocessing"] {
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
            properties["runOnlyForDeploymentPostprocessing"] = newValue ? "1" : "0"
            save()
        }
    }
    
    public var scriptSource: String {
        get {
            if let valueObject: AnyObject = properties["shellScript"] {
                if let value = valueObject as? String {
                    return value
                }
            }
            
            return ""
        }
        
        set {
            properties["shellScript"] = newValue
            save()
        }
    }
    
    // inputFiles and outputFiles may contain Xcode $(variables).
    
    public var inputFiles: [String]? {
        get {
            if let valueObject: AnyObject = properties["inputFiles"] {
                if let value = valueObject as? [String] {
                    return value
                }
            }
            
            return nil
        }
        
        set {
            if let array = newValue {
                properties["inputFiles"] = array
            } else {
                properties.removeValueForKey("inputFiles")
            }
            
            save()
        }
    }
    
    public var outputFiles: [String]? {
        get {
            if let valueObject: AnyObject = properties["outputFiles"] {
                if let value = valueObject as? [String] {
                    return value
                }
            }
            
            return nil
        }
        
        set {
            if let array = newValue {
                properties["outputFiles"] = array
            } else {
                properties.removeValueForKey("outputFiles")
            }
            
            save()
        }
    }
}
