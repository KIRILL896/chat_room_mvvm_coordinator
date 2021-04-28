//
//  UserNetworkRouter.swift
//  Liveroom
//
//  Created by отмеченные on 24.10.2021.
//

import Foundation
import Alamofire

public enum UserNetworkRouter: URLRequestConvertible {
    case auth([String: Any])
    case refreshToken([String: Any])
    case checkNickname([String: Any])
    case updateNickname([String: Any])
    case registerUser([String: Any])
    case sendAvatar
    case getListEmail([String: Any])
    case validateEmail([String: Any])
    case checkConfirmationEmail([String: Any])
    case getProfile(String?)
    case sendAboutMySelf(String)
    case getNotifications
    case getSubscribers
    case getSubscribed
    case getFriends
    case getEvents(String)
    case createEvent([String:Any])
    case updateNotifyFrequency(String)
    case updateNotifyRoom(Int)
    case updateLanguage(String)
    case createOTPCode
    
    
    var relativePath: String {
        let path: String
        switch self {
        case .auth:
            path = "/user/auth"
        case .refreshToken:
            path = "/user/auth/refresh"
        case .checkNickname:
            path = "/user/nickname/check"
        case .updateNickname:
            path = "/user/profile/update"
        case .registerUser:
            path = "/user/profile/update"
        case .sendAvatar:
            path = "/user/profile/update"
        case .getListEmail:
            path = "/user/email/list"
        case .validateEmail:
            path = "/user/email/validate"
        case .checkConfirmationEmail:
            path = "/user/email/approve/check"
        case .getProfile:
            path = "/user/profile"
        case .getSubscribers:
            path = "/subscriber/list"
        case .getSubscribed:
            path = "/subscriber/list"
        case .getFriends:
            path = "/subscriber/list"
        case .sendAboutMySelf,
             .updateNotifyFrequency,
             .updateNotifyRoom,
             .updateLanguage:
            path = "/user/profile/update"
        case .createOTPCode:
            path = "/user/otp/create"
        case .getEvents:
            path = "/event/list"
        case .createEvent:
            path = "event/create"
        case .getNotifications:
            path = "notification/list"
        }
        return path
    }
    
    var method: HTTPMethod {
        switch self {
        case .auth,
             .refreshToken,
             .checkNickname,
             .updateNickname,
             .registerUser,
             .sendAvatar,
             .getListEmail,
             .validateEmail,
             .checkConfirmationEmail,
             .sendAboutMySelf,
             .updateNotifyFrequency,
             .updateNotifyRoom,
             .updateLanguage,
             .createOTPCode,
             .createEvent:
            return .post
        case .getProfile,
             .getSubscribers,
             .getSubscribed,
             .getFriends,
             .getEvents,
             .getNotifications:
            return .get
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        
        let params: ([String: Any]?) = {
            switch self {
                case .auth(let json),
                     .refreshToken(let json),
                     .checkNickname(let json),
                     .updateNickname(let json),
                     .registerUser(let json),
                     .getListEmail(let json),
                     .validateEmail(let json),
                     .checkConfirmationEmail(let json):
                     return (json)
                case .sendAvatar,
                     .createOTPCode:
                    return nil
                case .getProfile(let id):
                    if let id = id {
                        return ["id": "\(id)"]
                    } else {
                        return nil
                    }
                case .sendAboutMySelf(let about):
                    return ["about": "\(about)"]
                case .getSubscribers:
                    return ["type": "2"]
                case .getFriends:
                return ["type": "3"]
                case .getSubscribed:
                    return ["type": "1"]
                case .updateNotifyFrequency(let code):
                    return ["notify_frequency": "\(code)"]
                case .updateNotifyRoom(let int):
                    return ["notify_room": int]
                case .updateLanguage(let code):
                    return ["language_code": "\(code)"]
                case .getNotifications:
                    return ["limit": 50, "offset": 0]
                case .getEvents(let type):
                    return ["limit": 50, "offset": 0, "type": type]
                case .createEvent(let json):
                    return json
                }
        }()
        
        let url: URL = {
            return URL(string: Constants.serverHost)!.appendingPathComponent(relativePath)
        }()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let encoding: ParameterEncoding = {
            switch method {
                case .get:
                    return URLEncoding.default
                default:
                    return JSONEncoding.default
            }
        }()
        
        return try encoding.encode(urlRequest, with: params)
    }
}
