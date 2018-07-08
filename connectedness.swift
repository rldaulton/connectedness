//
//  connectedness.swift
//
//
//  Created by Ryan Daulton on 10/4/16.
//  Copyright © 2016 Ryan Daulton. All rights reserved.
//  


import Foundation
import SystemConfiguration

public func connectedToNetwork() {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        print("Network Unreachable - Zero Address")
        return
    }
    
    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        print("Network Unreachable - Check Flags")
        return
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    connectedSpeed().testDownloadSpeedWithTimout(timeout: 5.0) { (megabytesPerSecond, error) -> () in
        
        if ((error == nil) && isReachable && !needsConnection) {
            if megabytesPerSecond!>=0.05 {
                print("\n       | Connected |")
                print("=======Network Speed=======\nMBps: \(megabytesPerSecond!)\nerror: \(String(describing: error))\n=======-------------=======\n")
            }else{
                print("\n       ? Connected ?")
                print("*======| WEAK SIGNAL |======*\nMBps: \(megabytesPerSecond!)\nerror: \(String(describing: error))\n*=======-------------=======*\n")
            }
        }else{
            print("NETWORK ERROR: \(String(describing: error))")
            return
        }
    }
    
}

public class connectedSpeed: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    ////
    
    var startTime: CFAbsoluteTime!
    var stopTime: CFAbsoluteTime!
    var bytesReceived: Int!
    var speedTestCompletionHandler: ((_ megabytesPerSecond: Double?, _ error: Error?) -> ())!
    
    /// Test speed of download
    ///
    /// Test the speed of a connection by downloading some predetermined resource. Alternatively, you could add the
    /// URL of what to use for testing the connection as a parameter to this method.
    ///
    /// - parameter timeout:             The maximum amount of time for the request.
    /// - parameter completionHandler:   The block to be called when the request finishes (or times out).
    ///                                  The error parameter to this closure indicates whether there was an error downloading
    ///                                  the resource (other than timeout).
    ///
    /// - note:                          Note, the timeout parameter doesn't have to be enough to download the entire
    ///                                  resource, but rather just sufficiently long enough to measure the speed of the download.
    
    public func testDownloadSpeedWithTimout(timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: Double?, _ error: Error?) -> ()) {
        let url =  URL(string: "http://insert.your.site.here/yourfile")!
        
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        speedTestCompletionHandler = completionHandler
        
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        session.dataTask(with: url).resume()

    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        bytesReceived! += data.count
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let elapsed = stopTime - startTime
        guard elapsed != 0 && (error == nil || (error?._domain == NSURLErrorDomain && error?._code == NSURLErrorTimedOut)) else {
            speedTestCompletionHandler(nil, error)
            return
        }
        
        let speed = elapsed != 0 ? Double(bytesReceived) / elapsed / 1024.0 / 1024.0 : -1
        speedTestCompletionHandler(speed, nil)
    }
    
    /////
    
}

