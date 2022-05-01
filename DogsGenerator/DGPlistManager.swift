//
//  DGPlistManager.swift
//  DogsGenerator
//
//  Created by Thangarajan K on 01/05/22.
//

import Foundation

struct Plist {
    
    let name: String
    
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
        return path
    }
    
    var destPath:String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {
        
        self.name = name
        
        let fileManager = FileManager.default
        
        guard let source = sourcePath else {
            plistManagerPrint("WARNING: The \(name).plist could not be initialized because it does not exist in the main bundle. Unable to copy file into the Document Directory of the app. Please add a plist file named \(name).plist into the main bundle (your project).")
            return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else {
            plistManagerPrint("The \(name).plist already exist.")
            return nil }
        
        if !fileManager.fileExists(atPath: destination) {
            
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                plistManagerPrint("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() throws -> NSDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            throw SwiftyPlistManagerError.fileDoesNotExist
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func addValuesToPlistFile(dictionary: NSDictionary) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !dictionary.write(toFile: destPath!, atomically: false) {
                print("File not written successfully")
                plistManagerPrint("File not written successfully")
                throw SwiftyPlistManagerError.fileNotWritten
            }
        } else {
            print("File not written successfully")
            plistManagerPrint("File does not exist")
            throw SwiftyPlistManagerError.fileDoesNotExist
        }
    }
    
}

public enum SwiftyPlistManagerError: Error {
    case fileNotWritten
    case fileDoesNotExist
    case fileUnavailable
    case fileAlreadyEmpty
    case keyValuePairAlreadyExists
    case keyValuePairDoesNotExist
}

public class DGPlistManager {
    
    public static let shared = DGPlistManager()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    var logPlistManager: Bool = false
    
    public func start(plistNames: [String], logging: Bool) {
        
        logPlistManager = logging
        
        plistManagerPrint("Starting SwiftyPlistManager . . .")
        
        var itemCount = 0
        for plistName in plistNames {
            itemCount += 1
            if let _ = Plist(name: plistName) {
                plistManagerPrint("Initialized '\(plistName).plist'")
            }
        }
        
        if itemCount == plistNames.count {
            plistManagerPrint("Initialization complete.")
        }
        
    }
    
    public func addNew(_ value: Any, key: String, toPlistWithName: String, completion:(_ error :SwiftyPlistManagerError?) -> ()) {
        plistManagerPrint("Starting to add value '\(value)' for key '\(key)' to '\(toPlistWithName).plist' . . .")
        if !keyAlreadyExists(key: key, inPlistWithName: toPlistWithName) {
            if let plist = Plist(name: toPlistWithName) {
                
                guard let dict = plist.getMutablePlistFile() else {
                    plistManagerPrint("Unable to get '\(toPlistWithName).plist'")
                    completion(.fileUnavailable)
                    return
                }
                
                dict[key] = value
                
                do {
                    try plist.addValuesToPlistFile(dictionary: dict)
                    completion(nil)
                } catch {
                    plistManagerPrint(error)
                    completion(error as? SwiftyPlistManagerError)
                }
                
                logAction(for: plist, withPlistName: toPlistWithName)
                
            } else {
                plistManagerPrint("Unable to get '\(toPlistWithName).plist'")
                completion(.fileUnavailable)
            }
        } else {
            plistManagerPrint("Value for key '\(key)' already exists. Not saving value. Not overwriting value.")
            completion(.keyValuePairAlreadyExists)
        }
    }
    
    public func removeKeyValuePair(for key: String, fromPlistWithName: String, completion:(_ error :SwiftyPlistManagerError?) -> ()) {
        plistManagerPrint("Starting to remove Key-Value pair for '\(key)' from '\(fromPlistWithName).plist' . . .")
        if keyAlreadyExists(key: key, inPlistWithName: fromPlistWithName) {
            if let plist = Plist(name: fromPlistWithName) {
                
                guard let dict = plist.getMutablePlistFile() else {
                    plistManagerPrint("Unable to get '\(fromPlistWithName).plist'")
                    completion(.fileUnavailable)
                    return
                }
                dict.removeObject(forKey: key)
                
                do {
                    try plist.addValuesToPlistFile(dictionary: dict)
                    completion(nil)
                } catch {
                    plistManagerPrint(error)
                    completion(error as? SwiftyPlistManagerError)
                }
                
                logAction(for: plist, withPlistName: fromPlistWithName)
                
            } else {
                plistManagerPrint("Unable to get '\(fromPlistWithName).plist'")
                completion(.fileUnavailable)
            }
        } else {
            plistManagerPrint("Key-Value pair for key '\(key)' does not exists. Remove canceled.")
            completion(.keyValuePairDoesNotExist)
        }
        
    }
    
    public func removeAllKeyValuePairs(fromPlistWithName: String, completion:(_ error :SwiftyPlistManagerError?) -> ()) {
        
        if let plist = Plist(name: fromPlistWithName) {
            
            guard let dict = plist.getMutablePlistFile() else {
                plistManagerPrint("Unable to get '\(fromPlistWithName).plist'")
                completion(.fileUnavailable)
                return
            }
            
            let keys = Array(dict.allKeys)
            
            if keys.count != 0 {
                dict.removeAllObjects()
            } else {
                plistManagerPrint("'\(fromPlistWithName).plist' is already empty. Removal of all key-value pairs canceled.")
                completion(.fileAlreadyEmpty)
                return
            }
            
            do {
                try plist.addValuesToPlistFile(dictionary: dict)
                completion(nil)
            } catch {
                plistManagerPrint(error)
                completion(error as? SwiftyPlistManagerError)
            }
            
            logAction(for: plist, withPlistName: fromPlistWithName)
            
        } else {
            plistManagerPrint("Unable to get '\(fromPlistWithName).plist'")
            completion(.fileUnavailable)
        }
    }
    
    public func addNewOrSave(_ value: Any, forKey: String, toPlistWithName: String, completion:(_ error :SwiftyPlistManagerError?) -> ()) {
        if keyAlreadyExists(key: forKey, inPlistWithName: toPlistWithName){
            save(value, forKey: forKey, toPlistWithName: toPlistWithName, completion: completion)
        }else{
            addNew(value, key: forKey, toPlistWithName: toPlistWithName, completion: completion)
        }
    }
    
    public func save(_ value: Any, forKey: String, toPlistWithName: String, completion:(_ error :SwiftyPlistManagerError?) -> ()) {
        
        if let plist = Plist(name: toPlistWithName) {
            
            guard let dict = plist.getMutablePlistFile() else {
                plistManagerPrint("Unable to get '\(toPlistWithName).plist'")
                completion(.fileUnavailable)
                return
            }
            
            if let dictValue = dict[forKey] {
                
                if type(of: value) != type(of: dictValue){
                    plistManagerPrint("WARNING: You are saving a '\(type(of: value))' typed value into a '\(type(of: dictValue))' typed value. Best practice is to save Int values to Int fields, String values to String fields etc. (For example: '_NSContiguousString' to '__NSCFString' is ok too; they are both String types) If you believe that this mismatch in the types of the values is ok and will not break your code than disregard this message.")
                }
                
                dict[forKey] = value
                
            }
            
            print(dict)
            do {
                try plist.addValuesToPlistFile(dictionary: dict)
                completion(nil)
            } catch {
                plistManagerPrint(error)
                completion(error as? SwiftyPlistManagerError)
            }
            
            logAction(for: plist, withPlistName: toPlistWithName)
            
        } else {
            plistManagerPrint("Unable to get '\(toPlistWithName).plist'")
            completion(.fileUnavailable)
        }
    }
    
    public func fetchValue(for key: String, fromPlistWithName: String) -> Any? {
        
        guard let plist = Plist(name: fromPlistWithName),
              let dict = plist.getMutablePlistFile() else {
                  plistManagerPrint("Unable to get '\(fromPlistWithName).plist'")
                  return nil
              }
        
        guard let value = dict[key] else {
            plistManagerPrint("WARNING: The Value for key '\(key)' does not exist in '\(fromPlistWithName).plist'! Please, check your spelling.")
            return nil
        }
        
        plistManagerPrint("Sending value to completion handler: \(value)")
        return value
        
    }
    
    public func getValue(for key: String, fromPlistWithName: String, completion:(_ result : Any?, _ error :SwiftyPlistManagerError?) -> ()) {
        
        guard let plist = Plist(name: fromPlistWithName),
              let dict = plist.getMutablePlistFile() else {
                  plistManagerPrint("Unable to get '\(fromPlistWithName).plist'")
                  completion(nil, .fileUnavailable)
                  return
              }
        
        guard let value = dict[key] else {
            plistManagerPrint("WARNING: The Value for key '\(key)' does not exist in '\(fromPlistWithName).plist'! Please, check your spelling.")
            completion(nil, .keyValuePairDoesNotExist)
            return
        }
        
        plistManagerPrint("Sending value to completion handler: \(value)")
        completion(value, nil)
        
    }
    
    func keyAlreadyExists(key: String, inPlistWithName: String) -> Bool {
        
        guard let plist = Plist(name: inPlistWithName),
              let dict = plist.getMutablePlistFile() else { return false }
        
        let keys = dict.allKeys
        return keys.contains { $0 as? String == key }
        
    }
    
    func getAllKeys(inPlistWithName: String) -> [String]? {
        guard let plist = Plist(name: inPlistWithName),
              let dict = plist.getMutablePlistFile() else { return nil }
        
        let keys = dict.allKeys
        return keys as? [String]
    }
    
    func logAction(for plist:Plist, withPlistName: String) {
        if logPlistManager {
            
            plistManagerPrint("An Action has been performed. You can check if it went ok by taking a look at the current content of the '\(withPlistName).plist' file: ")
            
            do {
                let plistValues = try plist.getValuesInPlistFile()
                plistManagerPrint("\(plistValues ?? [:])")
            } catch {
                plistManagerPrint("Could not retreive '\(withPlistName).plist' values.")
                plistManagerPrint(error)
            }
            
        }
    }
    
}

func plistManagerPrint(_ text: Any) {
    if DGPlistManager.shared.logPlistManager {
        print("[SwiftyPlistManager]", text)
    }
}


