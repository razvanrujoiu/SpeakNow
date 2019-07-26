//
//  AudioRecordService.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 26/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import Foundation
import RxSwift

public class AudioRecordService {
    private let audioRecordAPI: AudioRecordAPI
    
    init(audioRecordAPI: AudioRecordAPI) {
        self.audioRecordAPI = audioRecordAPI
    }
    
    public func getAudioRecords() -> Single<[AudioRecord]> {
        return audioRecordAPI.getAudioRecords();
    }
}
