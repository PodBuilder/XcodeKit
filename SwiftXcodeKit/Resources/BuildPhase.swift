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

// Note: BuildPhase is an abstract class; use one of its subclasses instead.
public class BuildPhase: Resource {
    public var buildFileReferences: [BuildFile]? {
        get {
            if let arrayObject: AnyObject = properties["files"] {
                if let array = arrayObject as? [AnyObject] {
                    var retval = [BuildFile]()
                    
                    for item in array {
                        if let oid = item as? OID {
                            let buildFile: BuildFile? = registry.findObject(identifier: oid)
                            if let actualFile = buildFile {
                                retval.append(actualFile)
                            }
                        } else if let oid = item as? String {
                            let buildFile: BuildFile? = registry.findObject(identifier: OID(key: oid))
                            if let actualFile = buildFile {
                                retval.append(actualFile)
                            }
                        }
                    }
                    
                    return retval
                }
            }
            
            return nil
        }
    }
    
    public func findBuildFileWithName(name: String) -> BuildFile? {
        if let arrayObject: AnyObject = properties["files"] {
            if let array = arrayObject as? [AnyObject] {
                if let oids = array as? [OID] {
                    for ident in oids {
                        let file: BuildFile? = registry.findObject(identifier: ident)
                        if file?.fileReference?.name == name {
                            return file
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    public func findBuildFileWithPath(path: String) -> BuildFile? {
        if let arrayObject: AnyObject = properties["files"] {
            if let array = arrayObject as? [AnyObject] {
                if let oids = array as? [OID] {
                    for ident in oids {
                        let file: BuildFile? = registry.findObject(identifier: ident)
                        if file?.fileReference?.path == path {
                            return file
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    public func addBuildFileWithReference(reference: FileReference, buildSettings: [String: AnyObject]?) -> Bool {
        if findBuildFileWithName(reference.name) != nil {
            return false
        }
        
        if findBuildFileWithPath(reference.path) != nil {
            return false
        }
        
        let file = BuildFile.create(fileReference: reference, buildSettings: buildSettings, inRegistry: &registry)
        registry.putResource(file)
        
        if let arrayObject: AnyObject = properties["files"] {
            if var array = arrayObject as? [AnyObject] {
                array.append(file.identifier)
            }
        }
        
        save()
        return true
    }
}
