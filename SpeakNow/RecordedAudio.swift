//
//  RecordedAudio.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 25/10/2018.
//  Copyright © 2018 Rujoiu Razvan. All rights reserved.
//

import Foundation
import RealmSwift

class RecordedAudio: Object {
    @objc dynamic var title: String!
    @objc dynamic var date: Date!
}
