////
////  ViewController.swift
////  SpeakNow
////
////  Created by Razvan Rujoiu on 25/10/2018.
////  Copyright © 2018 Rujoiu Razvan. All rights reserved.
////
//
//import UIKit
//import AVFoundation
////import Starscream
//
//
//
//class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
//
//    private var audioRecorder: AVAudioRecorder!
//   // private var recordedAudio: RecordedAudio!

//    private var audioPlayer: AVAudioPlayer
//   // priavate var recordings : Results<RecordedAudio>!
//    @IBOutlet weak var recordingsTableView: UITableView!
//    @IBOutlet weak var recordingProgress: UILabel!
//    @IBOutlet weak var recordButton: UIButton!
//    @IBOutlet weak var stopButton: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTableView()
//        setupBackground()
//        recordingProgress.isHidden = true
//
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        stopButton.isHidden = true
//    }
//    
//    func setupBackground() {
//        view.backgroundColor = UIColor.darkGray
//        self.recordingsTableView.backgroundColor = UIColor.darkGray
//        self.recordingProgress.textColor = UIColor.white
//    }
//
//
//    @IBAction func startRecording(_ sender: Any) {
//        recordingProgress.isHidden = false
//        recordButton.isEnabled = false
//        stopButton.isHidden = false
//
//        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//
//        let currentDateTime = NSDate()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy-HH-mm"
//        let recordingName = formatter.string(from: currentDateTime as Date) + ".wav"
//
//        let pathArray = [dirPath,recordingName]
//        let filePath = NSURL.fileURL(withPathComponents: pathArray)
//
//        let session = AVAudioSession.sharedInstance()
//
//        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
//
//        try! session.setActive(true)
//
//
//        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
//        audioRecorder.delegate = self
//        audioRecorder.isMeteringEnabled = true
//        audioRecorder.prepareToRecord()
//        audioRecorder.record()
//        
//    }
//    
//    func reloadTable() {
//        DispatchQueue.main.async {
//            self.recordingsTableView.reloadData()
//        }
//    }
//
//    
//    @IBAction func stopRecording(_ sender: Any) {
//        recordingProgress.isHidden = true
//        recordButton.isEnabled = true
//        stopButton.isHidden = true
//        audioRecorder.stop()
//
//        let audioSession = AVAudioSession.sharedInstance()
//        try! audioSession.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
//
//        DispatchQueue.main.async {
//             self.reloadTable()
//        }
//    }
//    

//}
//    
//extension ViewController:UITableViewDataSource, UITableViewDelegate {
//
//    func setupTableView() {
//        self.recordingsTableView.delegate = self
//        self.recordingsTableView.dataSource = self
//
//        DispatchQueue.main.async {
//            self.reloadTable()
//        }
//        
//    }
//    
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return recordings.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAudio", for: indexPath)
//       // let recording = self.recordings[indexPath.row]
//
//        
//        //Setup colors
//        cell.backgroundColor = UIColor.darkGray
//        cell.textLabel?.textColor = UIColor.white
//        cell.detailTextLabel?.textColor = UIColor.white
//        
//
//        //Assigning text fields
//        cell.textLabel?.text = recording.title
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy_HH:mm"
//        cell.detailTextLabel?.text = formatter.string(from: recording.date)
//        
//        return cell
//
//    }
//
//    
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let recording = self.recordings[indexPath.row]
//
//        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//
//        let path = dirPath + "/" + recording.title
//   
//
//        let urlPath = URL.init(fileURLWithPath: path)
//
//        var byteArray = readFile(path: urlPath)
//        print(byteArray)
//        
//        do {
//                audioPlayer = try! AVAudioPlayer(contentsOf: urlPath)
//                audioPlayer.delegate = self
//                audioPlayer.prepareToPlay()
//
//                audioPlayer.play()
//
//                print("playing audio")
//
//              //  socket.write(string: path)
//
//            } catch {
//                print("Error at playing recording when pressing cell or the filepath was null")
//                print(error.localizedDescription)
//            }
//        }
//
//
//    
//}
//
