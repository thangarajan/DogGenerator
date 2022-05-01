//
//  DoubleLinkedList.swift
//  DogsGenerator
//
//  Created by Thangarajan K on 01/05/22.
//

import UIKit

typealias DoublyLinkedListNode<T> = DoublyLinkedList<T>.Node<T>

class DoublyLinkedList<T> {
    class Node<T> {
        var payload: T
        var previous: Node<T>?
        var next: Node<T>?
        
        init(payload: T) {
            self.payload = payload
        }
    }
    
    private(set) var count: Int = 0
    
    var head: Node<T>?
    var tail: Node<T>?
    
    func addHead(_ payload: T) -> Node<T> {
        let node = Node(payload: payload)
        defer {
            head = node
            count += 1
        }
        
        guard let head = head else {
            tail = node
            return node
        }
        
        head.previous = node
        
        node.previous = nil
        node.next = head
        
        return node
    }
    
    func moveToHead(_ node: Node<T>) {
        guard node !== head else { return }
        let previous = node.previous
        let next = node.next
        
        previous?.next = next
        next?.previous = previous
        
        node.next = head
        node.previous = nil
        
        if node === tail {
            tail = previous
        }
        self.head?.previous = node
        self.head = node
    }
    
    func removeLast() -> Node<T>? {
        guard let tail = self.tail else { return nil }
        
        let previous = tail.previous
        previous?.next = nil
        self.tail = previous
        
        if count == 1 {
            head = nil
        }
        
        count -= 1
        
        return tail
    }
}
