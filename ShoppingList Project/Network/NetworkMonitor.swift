//
//  NetworkMonitor.swift
//  ShoppingList Project
//
//  Created by 임승섭 on 2023/09/09.
//

import UIKit
import Network


class NetworkMonitor {
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private let monitor: NWPathMonitor
    
    // get은 public, set은 private
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    static let shared = NetworkMonitor()
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    private func getConnectionType(_ path: NWPath) {
        
        if (path.usesInterfaceType(.wifi)) {
            connectionType = .wifi
            print("연결 상태 : wifi")
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("연결 상태 : cellular")
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            print("연결 상태 : ethernet")
        } else {
            connectionType = .unknown
            print("연결 상태 : unknown")
        }
    }
    
    
    public func startMonitoring() {
        print("start Monitoring")
        
        monitor.start(queue: DispatchQueue.global() )
        monitor.pathUpdateHandler = { [ weak self ] path in
            
            self?.isConnected = ( path.status == .satisfied )
            self?.getConnectionType(path)
            
            if self?.isConnected == true {
                print("연결 상태")
            } else {
                print("연결 끊김")
            }
            
        }
    }
    
    public func stopMonitoring() {
        print("stop Monitoring")
        
        monitor.cancel()
    }
    
    
    
}
