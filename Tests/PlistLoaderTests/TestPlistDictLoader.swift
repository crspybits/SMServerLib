import XCTest
import SMServerLib
import PerfectLib

class TestPlistDictLoader: XCTestCase {
    var plistFileName:String! = "TestPlistDictLoader.plist"
    var pathName:String! = "/tmp"
    
    override func setUp() {
        super.setUp()
        // A bit of a hack, but I can't figure out a way otherwise to access the install directory where the code is running.
        // See also http://stackoverflow.com/questions/41340114/server-side-swift-testing-code-that-uses-bundle
        // The only downside is that these tests don't test the `init(plistFileNameInBundle filename:String)` constructor that uses the Bundle.
        // Write the .plist file to a known location. Use only pure Swift methods.
        
        let plistPath = (pathName as NSString).appendingPathComponent(plistFileName)
        let plist = File(plistPath)
        try! plist.open(.write)
        try! plist.write(string: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
            "<plist version=\"1.0\">\n" +
            "<dict>\n" +
                "<key>MyString</key>\n" +
                "<string>Hello World!</string>\n" +
                "<key>MyInteger</key>\n" +
                "<integer>100</integer>\n" +
            "</dict>\n" +
            "</plist>\n"
        )
        
        plist.close()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: constructor tests
    
    func testThatNonExistentPlistFileThrowsError() {
        do {
            let _ = try PlistDictLoader(usingPath: "foo", andPlistFileName: "bar")
            XCTFail()
        } catch {
        }
    }
    
    func testThatExistingPlistFileDoesNotThrowError() {
        do {
            let _ = try PlistDictLoader(usingPath: pathName, andPlistFileName: plistFileName!)
        } catch {
            XCTFail()
        }
    }
    
    // MARK: Test `get` with integer values
    
    func testThatNonExistingNonRequiredIntValueIsNotNil() {
        let plist = try! PlistDictLoader(usingPath: pathName!, andPlistFileName: plistFileName!)
        XCTAssert(plist.get(varName: "NoIntegerThere", ofType: .intType) == nil)
    }
    
    func testThatExistingNonRequiredIntValueHasRightValue() {
        let plist = try! PlistDictLoader(usingPath: pathName!, andPlistFileName: plistFileName!)
        let result = plist.get(varName: "MyInteger", ofType: .intType)
        XCTAssert(result != nil)
        
        if case .intValue(let intResult) = result! {
            XCTAssert(intResult == 100)
        }
        else {
            XCTFail()
        }
    }

    // MARK: Test `get` with string values
    
    func testThatNonExistingNonRequiredStringValueIsNil() {
        let plist = try! PlistDictLoader(usingPath: pathName, andPlistFileName: plistFileName!)
        XCTAssert(plist.get(varName: "NoStringHere") == nil)
    }
    
    func testThatExistingNonRequiredStringValueHasRightValue() {
        let plist = try! PlistDictLoader(usingPath: pathName, andPlistFileName: plistFileName!)
        let result = plist.get(varName: "MyString")
        
        XCTAssert(result != nil)
        
        if case .stringValue(let strResult) = result! {
            XCTAssert(strResult == "Hello World!")
        }
        else {
            XCTFail()
        }
    }
    
    // MARK: Test `getRequired` with integer values

    func testThatNonExistingRequiredIntValueThrowsError() {
        let plist = try! PlistDictLoader(usingPath: pathName, andPlistFileName: plistFileName!)
        
        do {
            let _ = try plist.getRequired(varName: "Foobar", ofType: .intType)
            XCTFail()
        } catch {
        }
    }
    
    func testThatExistingRequiredIntValueHasRightValue() {
        let plist = try! PlistDictLoader(usingPath: pathName, andPlistFileName: plistFileName!)
        let result = try! plist.getRequired(varName: "MyInteger", ofType: .intType)
        
        if case .intValue(let intResult) = result {
            XCTAssert(intResult == 100)
        }
        else {
            XCTFail()
        }
    }
    
    // MARK: Test `getRequired` with string values
    
    func testThatNonExistingRequiredStringValueThrowsError() {
        let plist = try! PlistDictLoader(usingPath: pathName, andPlistFileName: plistFileName!)
        
        do {
            let _ = try plist.getRequired(varName: "Foobar")
            XCTFail()
        } catch {
        }
    }

    func testThatExistingRequiredStringValueHasRightValue() {
        let plist = try! PlistDictLoader(usingPath: pathName, andPlistFileName: plistFileName!)
        let result = try! plist.getRequired(varName: "MyString")
        
        if case .stringValue(let strResult) = result {
            XCTAssert(strResult == "Hello World!")
        }
        else {
            XCTFail()
        }
    }
}
