
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

class FileTest: XCTestCase {
    private var client: HiveClientHandle?
    private var file: FileClient?

    func test_0Upload() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.upload("/Users/liaihong/Desktop/test.txt", asRemoteFile: "hive/testIos.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_1Download() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.download("hive/testIos.txt").done{ output in
            let data: Data = output.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)! as! Data
            XCTAssertEqual(String(data: data, encoding: .utf8), "this is test file abcdefghijklmnopqrstuvwxyz")
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_2Delete() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.delete("hive/testIos_delete01.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_2_1Delete() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.delete("hive/f1/testIos_copy_1.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_2_2Delete() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.delete("hive/f2/f3/testIos_move_1.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_3Copy() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.copy("hive/testIos.txt", "hive/f1/testIos_copy_1.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_4Move() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.move("hive/f1/testIos_copy_1.txt", "hive/f2/f3/testIos_move_1.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_5Hash() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.hash("hive/f2/f3/testIos_move_1.txt").done{ re in
            XCTAssertTrue(true)
            print(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_6list() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.list("hive/f2/f3").done{ re in
            XCTAssertTrue(true)
            print(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func test_7Stat() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.stat("hive/f2/f3").done{ re in
            XCTAssertTrue(true)
            print(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            let doc = try testapp.getDocument()
            print("testapp doc ===")
            print(doc.toString())
            _ = try didapp.getDocument()
            print(doc.toString())
            let options: HiveClientOptions = HiveClientOptions()
            _ = options.setAuthenticator(VaultAuthenticator())
            options.setAuthenticationDIDDocument(doc)
                .setDidResolverUrl(resolver)
            _ = options.setLocalDataPath(localDataPath)
            HiveClientHandle.setVaultProvider(doc.subject.description, PROVIDER)
            self.client = try HiveClientHandle.createInstance(withOptions: options)
            let lock = XCTestExpectation(description: "wait for test.")
            _ = self.client?.getVault(doc.subject.description).get{ result in
                self.file = (result.files as! FileClient)
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 100.0)
        } catch {
            XCTFail()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}