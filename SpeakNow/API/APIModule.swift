//
//  APIModule.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 26/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import Foundation
import Alamofire
import Swinject
import SwinjectAutoregistration

public class APIModule: Assembly {
    
    public init() {
        
    }
    
    
    public func assemble(container: Container) {
        container.autoregister(AudioRecordAPI.self, initializer: AudioRecordAPI.init).inObjectScope(.container)
    }
    
    private static func configureSessionManager(adapter: RequestAdapter) ->  SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let manager = SessionManager(configuration: configuration)
        manager.adapter = adapter
        return manager
    }
    
}
