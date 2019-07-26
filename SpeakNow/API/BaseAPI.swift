//
//  BaseAPI.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 25/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

enum APIEnvironment: String {
    case local = "http://localhost:8080/audioRecords/"
}

enum NetworkError: Error {
    case httpCodeError(code: Int)
}

public struct APIError: Error {
    let error: String
    public init(_ error: String) {
        self.error = error
    }
}

typealias ResponseProcessor<T> = (JSON) throws -> T
typealias ErrorProcessor = (JSON) throws -> Void


public class BaseAPI {
    internal let httpClient: SessionManager
   
    
    
    required init(_ sessionManager: SessionManager) {
        self.httpClient = sessionManager
    }
    
    func call<T>(
        method: HTTPMethod = .get,
        endpoint: String,
        query: [String: Any]? = nil,
        env: APIEnvironment = .local,
        parameters: Parameters? = nil,
        headers: [String: String]? = nil,
        encoding: ParameterEncoding = URLEncoding.methodDependent,
        errorProcessor: ErrorProcessor? = nil,
        responseProcessor: @escaping ResponseProcessor<T>
        ) -> Single<T> {
        return Single.create { observer in
            var url = try! self.url(endpoint, env: env).asURL()
            
            if let query = query, !query.isEmpty,
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                let baseQuery = urlComponents.percentEncodedQuery.map { $0 + "&" } ?? ""
                urlComponents.percentEncodedQuery = baseQuery + self.serializeQueryParams(params: query)
                url = urlComponents.url!
            }
            let request = self.httpClient.request(
                    url,
                    method: method,
                    parameters: parameters,
                    encoding: encoding,
                    headers: headers)
            
            request.responseData { response in
                if let error = response.error {
                    observer(.error(error))
                } else {
                    do {
                        if (200..<299).contains(response.response?.statusCode ?? 0) {
                            let result = try responseProcessor(try JSON(data: response.data!))
                            observer(.success(result))
                        } else {
                            let json = try JSON(data: response.data!)
                            if let errorProcessor = errorProcessor {
                                try errorProcessor(json)
                            }
                            let error = json["error"].string
                            if let error = error {
                                throw APIError(error)
                            }
                            throw NetworkError.httpCodeError(code: response.response?.statusCode ?? 0)
                        }
                    } catch {
                        observer(.error(error))
                    }
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func serializeQueryParams(params: [String: Any]) -> String {
        var components: [(String, String)] = []
        for key in params.keys.sorted(by: < ) {
            let value = params[key]!
            components += URLEncoding.queryString.queryComponents(fromKey: key, value: value)
        }
       return components.map { "\($0)=\($1)" }.joined(separator: "&")
        
    }
    
    func path(_ template: String, params: Any...) -> String {
        let parts = template.split(separator: "/").map { String($0) }
        var nextIndex = 0
        return parts.map { part in
            if part.starts(with: ":") {
                guard nextIndex < params.count else {
                    fatalError("missing parameter \(part) in \(template)")
                }
                defer { nextIndex += 1 }
                return String(describing: params[nextIndex])
            }
            return part
            }.joined(separator: "/")
    }
    
    func url(_ path: String, env: APIEnvironment = .local) -> String {
        return env.rawValue.trimmingCharacters(in: ["/"]) + "/" + path.trimmingCharacters(in: ["/"])
    }
}
