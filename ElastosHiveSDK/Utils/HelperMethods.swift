import Foundation

@inline(__always) private func TAG() -> String { return "HelperMethods" }

class HelperMethods {
   class func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        return String.init(format: "%ld", Int(Date().timeIntervalSince1970))
    }

    class func getExpireTime(time: Int64) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")

        let dateNow = Date.init(timeIntervalSinceNow: TimeInterval(time))
        return String.init(format: "%ld", Int(dateNow.timeIntervalSince1970))
    }

    class func checkIsExpired(_ timeStemp: String) -> Bool {
        let currentTime = getCurrentTime()
        return currentTime > timeStemp;
    }

    class func getKeychain(_ key: String, _ account: KEYCHAIN_DRIVE_ACCOUNT) -> String? {
        let keychain: KeychainSwift = KeychainSwift()
        let account = keychain.get(account.rawValue)
        guard account != nil else {
            return nil
        }
        let jsonData:Data = account!.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        guard dict != nil else {
            return nil
        }
        let json = dict as? Dictionary<String, Any>
        guard json != nil else {
            return nil
        }
        let value = json![key]
        guard value != nil else {
            return nil
        }
        return (value as! String)
    }

    class func saveKeychain(_ account: KEYCHAIN_DRIVE_ACCOUNT, _ value: Dictionary<String, Any>) {
        if !JSONSerialization.isValidJSONObject(value) {
            Log.e(TAG(), "Key-Value is not valid json object")
            return
        }
        let data = try? JSONSerialization.data(withJSONObject: value, options: [])
        let jsonstring = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        guard jsonstring != nil else {
            Log.e(TAG(), "Save Key-Value for account :%s", account.rawValue)
            return
        }
        let keychain = KeychainSwift()
        keychain.set(jsonstring!, forKey: account.rawValue)
    }

    class func prePath(_ path: String) -> String {
        let index = path.range(of: "/", options: .backwards)?.lowerBound
        let str = index.map(path.prefix(upTo:)) ?? ""
        return String(str + "/")
    }

    class func endPath(_ path: String) -> String {
        let arr = path.components(separatedBy: "/")
        let str = arr.last ?? ""
        return String(str)
    }

    class func jsonToString(_ data: Data) -> String {
        let jsonString = String(data: data, encoding: .utf8)
        return jsonString ?? ""
    }
}