//
//  AsyncOperation.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 29.01.22.
//

import UIKit
import Foundation
import SwiftUI

class AsyncOperation: Operation {
    
    @objc private enum State: Int {
        case ready, executing, finished
        
        var keyPath: String {
            return ["isReady", "isExecuting", "isFinished"][rawValue]
        }
    }
    
    private var stateStore: State = .ready
    
    private let stateQueue = DispatchQueue(
        label: "com.epam.AsuncOperationsStateQueue",
        attributes: .concurrent)
    
    @objc private dynamic var state: State {
        get{
            return self.stateQueue.sync {
                self.stateStore
            }
        }
        set{
            self.willChangeValue(forKey: newValue.keyPath)
            self.stateQueue.async(flags: .barrier){
                self.stateStore = newValue
            }
            self.didChangeValue(forKey: newValue.keyPath)
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    final override var isExecuting: Bool {
        return state == .executing
    }
    
    final override var isFinished: Bool {
        return state == .finished
    }
    
    final override var isAsynchronous: Bool {
        return true
    }
    
    final override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }
        state = .executing
        main()
    }
    
    final func finish() {
        state = .finished
    }
}
