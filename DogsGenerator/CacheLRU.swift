import Foundation

struct CachePayload {
    let key: Int
    let value: Any
}

class CacheLRU<Key: Hashable, Value> {
    
    private let capacity: Int
    let list = DoublyLinkedList<CachePayload>()
    var nodesDict = [Key: DoublyLinkedListNode<CachePayload>]()
    let userDefaults = UserDefaults.standard

    init(capacity: Int) {
        self.capacity = max(0, capacity)
    }
    
    func setValue(_ value: Value, for key: Key) {
        let payload = CachePayload(key: key as! Int, value: value)
        
        if let node = nodesDict[key] {
            node.payload = payload
            list.moveToHead(node)
        } else {
            let node = list.addHead(payload)
            nodesDict[key] = node
        }
        self.saveDicIntoUserdefaults(value, "\(key)")

        if list.count > capacity {
            let nodeRemoved = list.removeLast()
            if let deletekey = nodeRemoved?.payload.key {
                removeLocalFilePath(self.getValue(for: deletekey as! Key) as? String)
                removePlistData("\(deletekey)")
                nodesDict[deletekey as! Key ] = nil
            }
        }
    }
        
    /// saving Dic into userdefaults
    func saveDicIntoUserdefaults(_ value: Any, _ key: String) {
        DGPlistManager.shared.addNew(value, key: key, toPlistWithName: plistName) { error in
            if error == nil {
                print("------------------->  Value '\(value)' successfully saved at Key '\(key ?? "")' int0")
            }
        }
    }
    
    func removePlistData(_ key: String) {
        DGPlistManager.shared.removeKeyValuePair(for: key, fromPlistWithName: plistName) { (err) in
          if err == nil {
            print("-------------> Key-Value pair successfully removed at Key '\(key)' from '\(plistName).plist'")
          }
        }
    }
    
    /// Removing last path index if maximum size exceed
    /// - Parameter filePath: last index filepath
    func removeLocalFilePath(_ filePath: String?) {
        let fileManager = FileManager.default
        if let nFilepath = filePath {
            if fileManager.fileExists(atPath: nFilepath) {
                try! fileManager.removeItem(atPath: nFilepath)
            }
        }
    }
    
    func getValue(for key: Key) -> Value? {
        guard let node = nodesDict[key] else { return nil }
        
        list.moveToHead(node)
        
        return node.payload.value as! Value
    }
}
