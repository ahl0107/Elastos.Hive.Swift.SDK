import Foundation

@objc(HiveDrive)
public class HiveDrive: NSObject {

   public typealias loginResponse = (_ error: HiveError?) -> Void

    /**
     * Create an instance with specific options.
     *
     * @param options TODO
     * @return An new drive instance.
     */
    public static func createInstance(_ param: DriveParameters) {
        let type: DriveType = param.getDriveType() // DriveParamers?
        switch type {
        case .oneDrive:
             OneDrive.createInstance(param as! OneDriveParameters)
        case .ownCloud:
             OwnCloudDrive.createInstance(param as! OwnCloudParameters)
        case .dropBox:
             DropboxDrive.createInstance(param as! DropBoxParameters)
        case .hiveIpfs:
             HiveIpfsDrive.createInstance(param as! HiveIpfsParameters)
        }
    }

    public static func sharedInstance(type: DriveType) -> HiveDrive? {
        switch type {
        case .oneDrive:
            return OneDrive.sharedInstance()
        case .ownCloud:
            return OwnCloudDrive.sharedInstance()
        case .dropBox:
            return DropboxDrive.sharedInstance()
        case .hiveIpfs:
            return HiveIpfsDrive.sharedInstance()
        }
    }
    @objc(getAuthHelper)
    func getAuthHelper() -> AuthHelper {
        return AuthHelper()
    }

    @objc(getDriveType)
    func getDriveType() -> DriveType {
        return DriveType.oneDrive
    }

    public func login(_ hiveError: @escaping (loginResponse))  {

    }

    @objc(getRootDir:)
    func getRootDir() throws -> HiveFile {
        return HiveFile()
    }

    @objc(createFile::)
    func createFile(pathname: String) throws -> HiveFile {
        return HiveFile()
    }

    @objc(getFile::)
    func getFile(pathname: String) throws -> HiveFile {
        return HiveFile()
    }
}
