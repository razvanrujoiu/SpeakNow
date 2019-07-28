//
//  AudioRecordTableViewCell.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 28/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import UIKit

class AudioRecordTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var audioRecordTitleLabel: UILabel!
    @IBOutlet private weak var audioRecordDateLabel: UILabel!
    
    public func load(audioRecord: AudioRecord) {
        self.audioRecordTitleLabel.text = audioRecord.title
        self.audioRecordDateLabel.text = audioRecord.date
    }
}
