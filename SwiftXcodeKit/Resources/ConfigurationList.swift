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

public class ConfigurationList: Resource {
    public override class var isaString: String {
        get {
            return "XCConfigurationList"
        }
    }
    
    public class func create(inout inRegistry registry: ObjectRegistry) -> ConfigurationList {
        let properties: [String: AnyObject] = [
            "isa": isaString,
            "buildConfigurations": [AnyObject](),
            "defaultConfigurationIsVisible": "0",
            "defaultConfigurationName": ""
        ]
        
        let configList = ConfigurationList(identifier: registry.generateOID(targetDescription: nil), inRegistry: registry, properties: properties)
        registry.putResource(configList)
        return configList
    }
    
    public var configurations: [Configuration]? {
        get {
            if let listObject: AnyObject = properties["buildConfigurations"] {
                if let list = listObject as? [AnyObject] {
                    var retval: [Configuration] = []
                    
                    for item in list {
                        if let oid = item as? OID {
                            if let config: Configuration = registry.findObject(identifier: oid) {
                                retval.append(config)
                            }
                        } else if let oid = item as? String {
                            if let config: Configuration = registry.findObject(identifier: OID(key: oid)) {
                                retval.append(config)
                            }
                        }
                    }
                    
                    return retval
                }
            }
            
            return nil
        }
    }
    
    public var defaultConfigurationName: String? {
        get {
            if let valueObject: AnyObject = properties["defaultConfigurationName"] {
                if let value = valueObject as? String {
                    return value
                }
            }
            
            return nil
        }
        
        set {
            if let name = newValue {
                properties["defaultConfigurationName"] = name
            } else {
                properties.removeValueForKey("defaultConfigurationName")
            }
            
            save()
        }
    }
    
    public func addConfigurationWithName(name: String) {
        addConfigurationWithName(name, block: { _ in })
    }
    
    public func addConfigurationWithName(name: String, block: (Configuration) -> ()) {
        let config = Configuration.createWithName(name, inRegistry: &registry)
        block(config)
        config.save()
        
        if let arrayObject: AnyObject = properties["buildConfigurations"] {
            if var array = arrayObject as? [AnyObject] {
                array.append(config.identifier)
            }
        }
        
        save()
    }
    
    public func removeConfigurationWithName(name: String) {
        var configToRemove: Configuration?
        if let array = configurations {
            for config in array {
                if config.name == name {
                    configToRemove = config
                    break
                }
            }
        }
        
        if let realConfig = configToRemove {
            if let arrayObject: AnyObject = properties["buildConfigurations"] {
                if var array = arrayObject as? [AnyObject] {
                    let newArray = array.filter({
                        (element) -> Bool in
                        if let config = element as? Configuration {
                            if config == configToRemove {
                                return false
                            }
                        }
                        
                        return true
                    })
                    
                    properties["buildConfigurations"] = newArray
                }
            }
        }
        
        save()
    }
}
