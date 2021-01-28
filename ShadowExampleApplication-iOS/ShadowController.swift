//
//  ShadowController.swift
//  ShadowExampleApplication-iOS
//
//  Created by Mafalda on 11/19/20.
//

import Foundation
import Network

import Logging
import Shadow

class ShadowController: ObservableObject
{
    @Published var chachaResult = "Untested"
    @Published var aes128Result = "Untested"
    
    static let sharedInstance = ShadowController()
    
    // Create a Logger for shadowFactory to use
    let logger = Logger(label: "Shadow Logger")
    let host = NWEndpoint.Host("159.203.158.90")
    
    init()
    {
        LoggingSystem.bootstrap(StreamLogHandler.standardError)
    }
    
    func testShadowChaCha()
    {
        // Create a Shadowsocks config
        let chachaShadowConfig = ShadowConfig(password: "1234", mode: .CHACHA20_IETF_POLY1305)
        testShadow(withConfig: chachaShadowConfig, andPort: 2345)
    }
    
    func testShadowAES128()
    {
        let aes156Config = ShadowConfig(password: "1234", mode: .AES_128_GCM)
        testShadow(withConfig: aes156Config, andPort: 2346)
    }
    
    func testShadowAES256()
    {
        let aes156Config = ShadowConfig(password: "1234", mode: .AES_256_GCM)
        testShadow(withConfig: aes156Config, andPort: 2347)
    }
    
    func testShadow(withConfig config: ShadowConfig, andPort port: UInt16)
    {
        // Make sure that we were able to resolve our port (this should never fail)
        guard let port = NWEndpoint.Port(rawValue: port)
            else
        {
            print("\nUnable to initialize port.\n")
            return
        }
        
        // Create a Connection Factory
        let shadowFactory = ShadowConnectionFactory(host: host, port: port, config: config, logger: logger)
        
        // Create a Connection
        guard var shadowConnection = shadowFactory.connect(using: .tcp)
            else
        {
            return
        }
        
        shadowConnection.stateUpdateHandler =
        {
            state in
            
            switch state
            {
            case NWConnection.State.ready:
                print("\nConnected state ready\n")
                
                // Write to the web server
                shadowConnection.send(content: Data("GET / HTTP/1.0\r\n\r\n"), contentContext: .defaultMessage, isComplete: true, completion: NWConnection.SendCompletion.contentProcessed(
                {
                    (maybeError) in
                    
                    if let sendError = maybeError
                    {
                        print("Send Error: \(sendError)")
                        return
                    }
                        
                    // Read the response
                    shadowConnection.receive(minimumIncompleteLength: 4, maximumLength: 100)
                    {
                        (maybeData, maybeContext, isComplete, maybeReceiveError) in
                        
                        if let receiveError = maybeReceiveError
                        {
                            print("Got a receive error \(receiveError)")
                            return
                        }
                        
                        // Print the response as a string
                        if let data = maybeData
                        {
                            print("👉 Received a response:")
                            print(data.string)
                        }
                    }
                }))
            default:
                print("\nReceived a state other than ready: \(state)\n")
                return
            }
        }
        
        shadowConnection.start(queue: .global())
    }
}
