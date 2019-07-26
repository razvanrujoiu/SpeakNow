//
//  AudioRecordAPI.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 25/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

class AudioRecordAPI: BaseAPI {
    
    public func getAudioRecords() -> Single<Array<AudioRecord>> {
        return call(endpoint: "/allRecords") { json in
            json["audioRecords"].arrayValue.map { self.deserializeAudioRecord(json: $0)
            }
        }
    }
    
    func deserializeAudioRecord(json: JSON) -> AudioRecord {
        return AudioRecord(id: json["id"].intValue,
                           title: json["title"].stringValue,
                           content: json["content"].arrayObject as! [UInt8]
        )
    }
}
