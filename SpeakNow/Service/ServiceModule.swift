//
//  ServiceModule.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 26/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

public class ServiceModule: Assembly {
   
    public init() {
        
    }
    
    public func assemble(container: Container) {
        container.autoregister(AudioRecordService.self, initializer: AudioRecordService.init).inObjectScope(.container)
    }
}
