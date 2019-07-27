//
//  AudioRecordService.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 27/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import UIKit

class AudioRecordService: NSObject {
    public static let shared = AudioRecordService()
    
    func fetchAudioRecords(completion: @escaping (Result<[AudioRecord], Error>) -> ()) {
        guard let url = URL(string: "http://localhost:8080/audioRecords/all") else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to fetch audio records: ", err)
                    return
                }
                guard let data = data else { return }
                do {
                    let audioRecords = try JSONDecoder().decode([AudioRecord].self, from: data)
                    completion(.success(audioRecords))
                } catch {
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
    
    func postAudioRecord(id: Int, title: String, content: [UInt8], completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "http://localhost:8080/audioRecords/addAudioRecord") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let params = ["id": id,
                      "title": title,
                      "content": content] as [String : Any]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
            URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
                guard let data = data else { return }
                completion(nil)
            }.resume()
        } catch {
            completion(error)
        }
    }
    
    func deleteAudioRecord(id: Int, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "http://localhost:8080/audioRecords/\(id)") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(err)
                    return
                }
            }
            
            if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                completion(NSError(domain: "", code: resp.statusCode, userInfo: [NSLocalizedDescriptionKey : errorString]))
                return
            }
            completion(nil)
        }.resume()
    }
}
