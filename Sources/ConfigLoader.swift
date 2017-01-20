//
//  ConfigLoader.swift
//  Pods
//
//  Created by Christopher Prince on 12/26/16.
//
//

import Foundation
import PerfectLib

open class ConfigLoader {
    
    public enum ConfigLoaderError : Error {
    case fileNotFound(name:String)
    case requiredVarNotFound(key:String)
    case requiredStringVarNotFound(key:String)
    case requiredIntVarNotFound(key:String)
    case plistNotAvailableOnLinux
    case failedLoadingJSONFile(name:String)
    }
    
    private var configDict:Dictionary<String, Any>!
    private var configType:ConfigType!
    
    public enum ConfigType {
    // Both assume top level structure of config file is a dictionary.
    case jsonDictionary
    case plistDictionary
    }
    
    // Filename must have any (e.g., .plist) extension.
    // throws an error if the file can't be found
    public init(fileNameInBundle filename:String, forConfigType configType:ConfigType) throws {
        let bundlePath = Bundle.main.bundlePath
        try setup(usingPath: bundlePath, andFileName: filename, forConfigType:configType)
    }
    
    // When you don't have access to the bundle. You don't have to give the trailing "/" on the path.
    public init(usingPath path:String, andFileName filename:String, forConfigType configType:ConfigType) throws {
        try setup(usingPath: path, andFileName: filename, forConfigType:configType)
    }
    
    private func setup(usingPath path:String, andFileName filename:String, forConfigType configType:ConfigType) throws {
        self.configType = configType
        
        // On Ubuntu, get: error: cannot convert value of type 'String' to type 'NSString' in coercion; See also http://stackoverflow.com/questions/37293388/cannot-convert-value-of-type-string-to-type-nsstring-in-coercion-when-i-use
        // let plistPath = (path as NSString).appendingPathComponent(filename)
        
        let configFilePath = NSString(string: path).appendingPathComponent(filename)
        
        switch configType {
        case .plistDictionary:
#if os(Linux)
            throw ConfigLoaderError.plistNotAvailableOnLinux
#else
            configDict = NSDictionary(contentsOfFile: configFilePath) as! Dictionary<String, Any>!
#endif
        case .jsonDictionary:
            // This segment of code from https://github.com/iamjono/JSONConfig/blob/master/Sources/jsonConfig.swift
            let file = File(configFilePath)
            do {
                try file.open(.read, permissions: .readUser)
                defer { file.close() }
                let txt = try file.readString()
                configDict = try txt.jsonDecode() as! Dictionary<String, Any>
            } catch {
                throw ConfigLoaderError.failedLoadingJSONFile(name: configFilePath)
            }
        }

        if configDict == nil {
            throw ConfigLoaderError.fileNotFound(name: configFilePath)
        }
    }
    
    public enum DictValue {
    case intValue(Int)
    case stringValue(String)
    }
    
    public enum DictType {
    case intType
    case stringType
    }
    
    open func get(varName:String, ofType type:DictType = .stringType) -> DictValue? {
        switch type {
        case .intType:
            switch configType! {
            case .jsonDictionary:
                // All values should be strings.
                if let str = configDict![varName] as? String, let int = Int(str) {
                    return .intValue(int)
                }
                
            case .plistDictionary:
                if let intVal = configDict![varName] as? Int {
                    return .intValue(intVal)
                }
            }
            
        case .stringType:
            if let str = configDict![varName] as? String {
                return .stringValue(str)
            }
        }
        
        return nil
    }
    
    // Throws an error if the value is not present.
    open func getRequired(varName:String, ofType type:DictType = .stringType) throws -> DictValue {
        if let result = get(varName: varName, ofType: type) {
            return result
        }
        else {
            throw ConfigLoaderError.requiredVarNotFound(key: varName)
        }
    }
    
    open func getInt(varName key:String) throws -> Int {
        if case .intValue(let intValue) = try self.getRequired(varName: key) {
            return intValue
        }
        throw ConfigLoaderError.requiredIntVarNotFound(key: key)
    }
    
    open func getString(varName key:String) throws -> String {
        if case .stringValue(let strValue) = try self.getRequired(varName: key) {
            return strValue
        }
        throw ConfigLoaderError.requiredStringVarNotFound(key: key)
    }
}
