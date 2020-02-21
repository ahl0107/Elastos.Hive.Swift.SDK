/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation

class OneDriveAPIs: NSObject {
    
    class func request(url: URLConvertible,
                       method: HTTPMethod = .get,
                       parameters: Parameters? = nil,
                       encoding: ParameterEncoding = URLEncoding.default,
                       headers: HTTPHeaders? = nil,
                       _ authHelper: ConnectHelper) -> HivePromise<JSON> {
        return HivePromise<JSON> { resolver in
            Alamofire.request(url, method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
                .responseJSON { dataResponse in
                    guard dataResponse.response?.statusCode != statusCode.unauthorized.rawValue else {
                        let error: HiveError = HiveError.failue(des: TOKEN_INVALID)
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == 200 else{
                        let responsejson: JSON = JSON(dataResponse.result.value as Any)
                        let errorjson: JSON = JSON(responsejson["error"])
                        let error: HiveError = HiveError.failue(des: errorjson["message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    var jsonData: JSON = JSON(dataResponse.result.value as Any)
                    jsonData = JSON(dataResponse.response?.allHeaderFields as Any)
                    resolver.fulfill(jsonData)
            }
        }
    }
    
    class func uploadWriteData(data: Data, to: URLConvertible,
                               method: HTTPMethod = .put,
                               headers: HTTPHeaders,
                            _ authHelper: ConnectHelper) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            Alamofire.upload(data,
                             to: to,
                             method: method,
                             headers: headers)
                .responseJSON(completionHandler: { dataResponse in
                    guard dataResponse.response?.statusCode != statusCode.unauthorized.rawValue else {
                        (authHelper as! OneDriveAuthHelper).token?.expiredTime = ""
                        let error: HiveError = HiveError.failue(des: TOKEN_INVALID)
                        resolver.reject(error)
                        return
                    }
                    guard dataResponse.response?.statusCode == statusCode.created.rawValue || dataResponse.response?.statusCode == statusCode.ok.rawValue else {
                        let json: JSON = JSON(JSON(dataResponse.result.value as Any)["error"])
                        let error: HiveError = HiveError.failue(des: json["message"].stringValue)
                        resolver.reject(error)
                        return
                    }
                    resolver.fulfill(Void())
            })
        }
    }

    class func getRemoteFile(url: URLConvertible, headers: HTTPHeaders, authHelper: ConnectHelper) -> HivePromise<Data> {
        return HivePromise<Data> {resolver in
            _ = authHelper.checkValid().done { result in
                Alamofire.request(url, method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: headers)
                    .responseData { dataResponse in
                        guard dataResponse.response?.statusCode != statusCode.unauthorized.rawValue else {
                            (authHelper as! OneDriveAuthHelper).token?.expiredTime = ""
                            let error: HiveError = HiveError.failue(des: TOKEN_INVALID)
                            resolver.reject(error)
                            return
                        }
                        guard dataResponse.response?.statusCode == 200 else{
                            let json: JSON = JSON(JSON(dataResponse.result.value as Any)["error"])
                            let error: HiveError = HiveError.failue(des: json["message"].stringValue)
                            resolver.reject(error)
                            return
                        }
                        let data: Data = dataResponse.data ?? Data()
                        resolver.fulfill(data)
                }
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
}
