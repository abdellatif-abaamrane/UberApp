//
//  NetworkChecker.swift
//  Twitter
//
//  Created by macbook-pro on 20/05/2020.
//

import Network




class NewtworkChecker {
    static let shared = NewtworkChecker()
    private init(){}
    private var monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "monitor.queue",attributes: .concurrent)
    func startMonitor(_ completionHandler : @escaping (_ status:NWPath.Status)->Void) {
        monitor.pathUpdateHandler = { path in
            completionHandler(path.status)
        }
        monitor.start(queue: queue)
    }
}
