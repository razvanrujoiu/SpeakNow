//
//  ViewController.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 25/10/2018.
//  Copyright © 2018 Rujoiu Razvan. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import SocketIO
//import Starscream



class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
    var audioRecorder: AVAudioRecorder!
    
    var recordedAudio: RecordedAudio!
    
    var audioPlayer: AVAudioPlayer!
    
     let realm = try! Realm()
    
    var recordings : Results<RecordedAudio>!
    
  //  var socket = WebSocket(url: URL(string: "ws://localhost:1337/")!)
    
    let manager = SocketManager(socketURL: URL(string: "https://localhost:8080")!, config: [.log(true), .compress])
  
    var socket : SocketIOClient!
    

    
    
    @IBOutlet weak var recordingsTableView: UITableView!
    
    @IBOutlet weak var recordingProgress: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
       // socket.delegate = self
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { data, socketAckEmitter in
            print("socket connected")
            print(data.description)
            print(SocketAckEmitter.description)
            
        }
        
        socket.on("currentAmount") { data, socketAckEmitter in
            guard let currentAmount = data[0] as? Double else { return }
            
            self.socket.emitWithAck("canUpdate", currentAmount).timingOut(after: 0, callback: { data in
                self.socket.emit("update", ["amount": currentAmount + 2.50])
            })
            
            socketAckEmitter.with("Got your current amount", "dude")
        }
        
        socket.connect()
        
        
        //socket.connect()
        
        setupBackground()
       
        recordingProgress.isHidden = true
        
        recordings = self.realm.objects(RecordedAudio.self)
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        stopButton.isHidden = true
    }
    
    func setupBackground() {
        view.backgroundColor = UIColor.darkGray
        self.recordingsTableView.backgroundColor = UIColor.darkGray
       self.recordingProgress.textColor = UIColor.white
    }
    
    
    @IBAction func startRecording(_ sender: Any) {
        recordingProgress.isHidden = false
        recordButton.isEnabled = false
        stopButton.isHidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy-HH-mm"
        let recordingName = formatter.string(from: currentDateTime as Date) + ".wav"
    
        
        
        let pathArray = [dirPath,recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        

        
        let session = AVAudioSession.sharedInstance()
       

        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeDefault, options: AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! session.setActive(true)
     
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.recordingsTableView.reloadData()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            self.recordedAudio = RecordedAudio()
            
            recordedAudio.title = recorder.url.lastPathComponent
            recordedAudio.date = Date()
            
            try! realm.write {
                realm.add(recordedAudio)
            }
            
            DispatchQueue.main.async {
                self.reloadTable()
            }
            
            
        } else {
            print("Recording was not succesful")
            recordButton.isEnabled = true
            stopButton.isHidden = true
        }
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        recordingProgress.isHidden = true
        recordButton.isEnabled = true
        stopButton.isHidden = true
        audioRecorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        
        DispatchQueue.main.async {
             self.reloadTable()
        }
       
    }
    
 
}
    
extension ViewController:UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        self.recordingsTableView.delegate = self
        self.recordingsTableView.dataSource = self
        
        DispatchQueue.main.async {
            self.reloadTable()
        }
        
    }
    

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAudio", for: indexPath)
        let recording = self.recordings[indexPath.row]
     
        
        //Setup colors
        cell.backgroundColor = UIColor.darkGray
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
        
        //Assigning text fields
        cell.textLabel?.text = recording.title
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy_HH:mm"
        cell.detailTextLabel?.text = formatter.string(from: recording.date)
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      
   
        let recording = self.recordings[indexPath.row]

        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
     
        let path = dirPath + "/" + recording.title
   

        let urlPath = URL.init(fileURLWithPath: path)


        do {

                audioPlayer = try! AVAudioPlayer(contentsOf: urlPath)
                 audioPlayer.delegate = self
                audioPlayer.prepareToPlay()

                audioPlayer.play()
            
                print("playing audio")
            
              //  socket.write(string: path)

            } catch {
                print("Error at playing recording when pressing cell or the filepath was null")
                print(error.localizedDescription)
            }
        }


    
}

//extension ViewController: WebSocketDelegate {
//    func websocketDidConnect(socket: WebSocketClient) {
//        socket.write(string: "Aplicatia client s-a connectat la socket")
//        print("S-a conectat clientul")
//    }
//
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        socket.write(string: "Clientul s-a deconectat")
//        print("Clientul s-a deconectat")
//    }
//
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        socket.write(string: "Message received")
//        print("Message received")
//    }
//
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        socket.write(string: "Data received")
//        print("Data receiverd")
//    }
//
//
//}
