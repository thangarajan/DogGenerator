import Foundation

class ListNode<Key, Value> {
    
    var value: Value
    var key: Key
    var next: ListNode?
    var previous: ListNode?
    
    init(value: Value, key: Key, next: ListNode? = nil, previous: ListNode? = nil) {
        self.value = value
        self.key = key
        self.next = next
        self.previous = previous
    }
}

class QueuedLinkedList<Key, Value> {
    var head: ListNode<Key, Value>?
    var tail: ListNode<Key, Value>?
    var count: Int = 0
    
    init() { }
    
    func add(_ key: Key, _ value: Value) -> ListNode<Key, Value>? {
        let node = ListNode(value: value, key: key)
        count += 1
        guard let temphead = head, let _ = tail else {
            head = node; tail = head; return node
        }
        
        temphead.previous = node
        node.next = head
        head = node
        return node
    }
    
    func removeLast() -> ListNode<Key, Value>? {
        guard let temptail = tail else { return nil }
        let previous = temptail.previous
        previous?.next = nil
        defer {
            count -= 1
            tail = previous
        }
        return tail
    }
    
    func moveNodeTowardsHead(node: ListNode<Key, Value>) {
        guard head !== node else { return }
        if tail === node { tail = node.previous }
        node.previous?.next = node.next
        node.next?.previous = node.previous
        
        node.next = head
        node.previous = nil
        
        head?.previous = node
        head = node
    }
}

class LRUCache <Key: Hashable, Value> {
    var data: [Key: ListNode<Key, Value>] = [:]
    let list: QueuedLinkedList<Key, Value> = QueuedLinkedList()
    var maximumSize: Int
    init(maximumSize: Int) {
        guard maximumSize > 0 else { fatalError() }
        self.maximumSize = maximumSize
    }
    
    func add(key: Key, value: Value) {
        print("Adding - \(value)")
        if let node = data[key] {
            list.moveNodeTowardsHead(node: node)
        } else {
            guard let node = list.add(key, value) else { fatalError() }
            data[key] =  node
        }
        
        if list.count > maximumSize {
            guard let node = list.removeLast() else { return }
            removeLocalFilePath(self.get(key: node.key) as? String)
            data[node.key] = nil
            print("removing - \(node.value)")
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
    
    func get(key: Key) -> Value? {
        guard let node = data[key] else { return nil }
        list.moveNodeTowardsHead(node: node)
        print("---------------------------------------------")
        print("Moved to head - \(node.value)")
        return node.value
    }
    
    func isValid(key: Key) -> Bool {
        return data[key] != nil
    }
}

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
