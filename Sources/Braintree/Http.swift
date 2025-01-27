//
//  Http.swift
//  Braintree
//
//  Created by Mihael Isaev on 27/09/2018.
//

import Foundation
import Vapor

public protocol BraintreeContent: Content {
    static var key: String { get }
}

public final class EmptyPayload: BraintreeContent {
    public static var key: String = ""
    public init() {}
}

public class Http {
    public typealias Future = EventLoopFuture
    
    public struct File: Codable {
        public var filename: String
        public var data: Data
        public var contentType: String?
        public var ext: String?
    }
    
    public enum RequestMethod: Int, Codable {
        case delete, get, post, put
    }
   
    public var configuration: Configuration
    
    public init (configuration: Configuration) {
        self.configuration = configuration
    }
    
     func headers()-> [String: String] {
        var headers: [String: String] = [:]
        headers["Braintree-Version"] = Configuration.grapthQLApiVersion
        headers["User-Agent"] = "Braintree Swift " + Configuration.version
        headers["X-ApiVersion"] = Configuration.apiVersion
        headers["Authorization"] =  "Basic " + configuration.gaphToken!
        headers["Content-Type"] = "application/json"
        return headers
    }
    
    
    private func encode<T>(_ payload: T) throws -> Data where T: Codable {
        let payload = try JSONEncoder().encode(payload)
        let payloadDict = try JSONSerialization.jsonObject(with: payload, options: .allowFragments)
        return try JSONSerialization.data(withJSONObject: payloadDict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
    }
    
    
    
    
    public func post<P>(_ url: String, payload: P, eventLoop: EventLoop) throws -> Future<Response> where P: Codable  {
        let payload = try encode(payload)
        let request = Request(url: configuration.baseURL + url, method: .POST, headers:  headers(), body: payload)
        return try send(request, eventLoop: eventLoop).flatMap { (reponse) -> EventLoopFuture<Response> in
            return eventLoop.makeSucceededFuture(reponse)
        }
    }
    
    public func send(_ req: Request, eventLoop:EventLoop) throws -> EventLoopFuture<Response> {
       guard let url = URL(string: req.url) else { throw BraintreeError(BraintreeErrorCase.server, reason: "Wrong URL") }
       var urlReq = URLRequest(url: url)
       urlReq.httpMethod = req.method.rawValue
       urlReq.httpBody = req.body ?? Data()
       req.headers.forEach { key, val in
           urlReq.addValue(val, forHTTPHeaderField: key.description)
       }
       let promise = eventLoop.makePromise(of: Response.self)
       let urlSession = URLSession(configuration: .default)
       urlSession.dataTask(with: urlReq) { data, urlResponse, error in
           if let error = error {
               promise.fail(error)
               return
           }
           
           guard let httpResponse = urlResponse as? HTTPURLResponse else {
               let error = BraintreeError(BraintreeErrorCase.server, reason: "URLResponse was not a HTTPURLResponse.")
               promise.fail(error)
               return
           }
           promise.succeed(Response(httpResponse, data: data))
           }.resume()
       return promise.futureResult
   }
    
    
    
    /*
    public func _getArray<T: Codable>(_ url: String) throws -> Future<[T]> {
        return try get(url).catchMap { error in
            let errStr = "\(error)"
            if errStr.contains("Index 0") { //TODO: remove that dirty hack
                return []
            }
            throw error
        }
    }
    
    public func get<R>(_ url: String) throws -> Future<R> where R: Codable {
        let request = Request(url: configuration.baseURL + url, method: .GET, headers: try headers(), body: nil)
        return try send(request).map { response in
            self.configuration.logger.log(.info, message: "\(Date()) \(request.method.rawValue) \(url)")
            self.configuration.logger.log(.fine, message: "\(Date()) \(request.method.rawValue) \(url) \(response.statusCode)")
            switch true {
            case response.statusCode == 200:
                return try self.decode(response: response)
            default:
                throw BraintreeError(BraintreeErrorCase.server, reason: "Unknown status: \(response.statusCode) url: \(self.configuration.baseURL + url)")
            }
        }
    }
    
    public func _postArray<R>(_ url: String) throws -> Future<[R]> where R: Codable {
        return try _postArray(url, payload: EmptyPayload())
    }
    
    public func _postArray<P, R>(_ url: String, payload: P) throws -> Future<[R]> where P: BraintreeContent, R: Codable {
        return try post(url, payload: payload).catchMap { error in
            let errStr = "\(error)"
            if errStr.contains("Index 0") { //TODO: remove that dirty hack
                return []
            }
            throw error
        }
    }
    
    public func post<R>(_ url: String) throws -> Future<R> where R: Codable {
        return try post(url, payload: EmptyPayload())
    }
    
    public func post<P, R>(_ url: String, payload: P, desiredCode: Int? = nil) throws -> Future<R> where P: BraintreeContent, R: Codable {
        let payload = try encode(payload)
        let request = Request(url: configuration.baseURL + url, method: .POST, headers: try headers(), body: payload)
        return try send(request).map { response in
            self.configuration.logger.log(.info, message: "\(Date()) \(request.method.rawValue) \(url)")
            self.configuration.logger.log(.fine, message: "\(Date()) \(request.method.rawValue) \(url) \(response.statusCode)")
            switch true {
            case response.statusCode == desiredCode ?? 200:
                return try self.decode(response: response)
            default:
                throw BraintreeError(BraintreeErrorCase.server, reason: "Braintree API returned status: \(response.statusCode)")
            }
        }
    }
    
    public func put<P, R>(_ url: String, payload: P) throws -> Future<R> where P: BraintreeContent, R: Codable {
        let payload = try encode(payload)
        let request = Request(url: configuration.baseURL + url, method: .PUT, headers: try headers(), body: payload)
        return try send(request).map { response in
            self.configuration.logger.log(.info, message: "\(Date()) \(request.method.rawValue) \(url)")
            self.configuration.logger.log(.fine, message: "\(Date()) \(request.method.rawValue) \(url) \(response.statusCode)")
            switch true {
            case response.statusCode == 200:
                return try self.decode(response: response)
            default:
                throw BraintreeError(BraintreeErrorCase.server)
            }
        }
    }
    
    public func delete<R>(_ url: String) throws -> Future<R> where R: Codable {
        let request = Request(url: configuration.baseURL + url, method: .DELETE, headers: try headers(), body: nil)
        return try send(request).map { response in
            self.configuration.logger.log(.info, message: "\(Date()) \(request.method.rawValue) \(url)")
            self.configuration.logger.log(.fine, message: "\(Date()) \(request.method.rawValue) \(url) \(response.statusCode)")
            switch true {
            case response.statusCode == 200:
                return try self.decode(response: response)
            default:
                throw BraintreeError(BraintreeErrorCase.server)
            }
        }
    }
    
   
    
    
    
    private func authorizationHeader() throws -> String {
        if let accessToken = configuration.accessToken {
            return "Bearer " + accessToken
        }
        var credentials = ""
        if let clientId = configuration.clientId, let clientSecret = configuration.clientSecret {
            credentials = clientId + ":" + clientSecret
        } else if let publicKey = configuration.publicKey, let privateKey = configuration.privateKey {
            credentials = publicKey + ":" + privateKey
        } else {
            throw BraintreeError(.configuration, reason: "Unable to get authorization credentials")
        }
        guard let base64String = credentials.data(using: .utf8)?.base64EncodedString() else {
            throw BraintreeError(.configuration, reason: "Unable to encode authorization credentials to base64")
        }
        return "Basic " + base64String.trimmingCharacters(in: .whitespaces)
    }
    
    
 */
    
   
}

public struct Request: Codable {
    var url: String
    enum Method: String, Codable {
        case POST
    }
    var method: Method
    var headers: [String: String] = [:]
    var body: Data?
}

public struct Response: Codable {
    var statusCode: Int
    var data: Data?
    
    init (_ resp: HTTPURLResponse, data: Data?) {
        self.statusCode = resp.statusCode
        self.data = data
    }
}

//TODO: use standard Vapor's client instead

