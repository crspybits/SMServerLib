import XCTest
@testable import SMServerLib
import PerfectLib
import Foundation

class TestConfigLoader: XCTestCase {
    var plistFileName:String! = "TestConfigLoader.plist"
    var jsonFileName:String! = "TestConfigLoader.json"
    var pathName:String! = "/tmp"
    
    override func setUp() {
        super.setUp()
        // This is a bit of a hack, but I can't figure out a way otherwise to access the install directory where the code is running.
        // See also http://stackoverflow.com/questions/41340114/server-side-swift-testing-code-that-uses-bundle
        // The only downside is that these tests don't test the constructor that uses the Bundle.
    
        let jsonPath = NSString(string: pathName).appendingPathComponent(jsonFileName)
        let json = File(jsonPath)
        try! json.open(.write)
        try! json.write(string:"{ \"MyString\": \"Hello World!\", \"MyInteger\": \"100\", \"MyBool\": \"false\", \"MyBool2\": \"true\" }")
        json.close()

#if os(macOS)
        let plistPath = NSString(string: pathName).appendingPathComponent(plistFileName)
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
                "<key>MyBool</key>\n" +
                "<false/>\n" +
                "<key>MyBool2</key>\n" +
                "<true/>\n" +
            "</dict>\n" +
            "</plist>\n"
        )
        
        plist.close()
#endif
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: constructor tests
    
    func testThatNonExistentJSONFileThrowsError() {
        do {
            let _ = try ConfigLoader(usingPath: "foo", andFileName: "bar", forConfigType: .jsonDictionary)
            XCTFail()
        } catch {
        }
    }
    
    func testThatExistingJSONFileDoesNotThrowError() {
        do {
            let _ = try ConfigLoader(usingPath: pathName, andFileName: jsonFileName!, forConfigType: .jsonDictionary)
        } catch {
            XCTFail()
        }
    }

#if os(macOS)
    func testThatNonExistentPlistFileThrowsError() {
        do {
            let _ = try ConfigLoader(usingPath: "foo", andFileName: "bar", forConfigType: .plistDictionary)
            XCTFail()
        } catch {
        }
    }
    
    func testThatExistingPlistFileDoesNotThrowError() {
        do {
            let _ = try ConfigLoader(usingPath: pathName, andFileName: plistFileName!, forConfigType: .plistDictionary)
        } catch {
            XCTFail()
        }
    }
#endif

    func fileForConfigType(_ configType: ConfigLoader.ConfigType) -> String {
        switch configType {
        case .plistDictionary:
            return plistFileName!
        case .jsonDictionary:
            return jsonFileName!
        }
    }
    
    // MARK: Test `get` with integer values
    
    func thatNonExistingNonRequiredIntValueIsNotNil(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        XCTAssert(config.get(varName: "NoIntegerThere", ofType: .intType) == nil)
    }

#if os(macOS)
    func testPlistThatNonExistingNonRequiredIntValueIsNotNil() {
        thatNonExistingNonRequiredIntValueIsNotNil(.plistDictionary)
    }
#endif

    func testJSONThatNonExistingNonRequiredIntValueIsNotNil() {
        thatNonExistingNonRequiredIntValueIsNotNil(.jsonDictionary)
    }
    
    func thatExistingNonRequiredIntValueHasRightValue(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        let result = config.get(varName: "MyInteger", ofType: .intType)
        XCTAssert(result != nil)
        
        if case .intValue(let intResult) = result! {
            XCTAssert(intResult == 100)
        }
        else {
            XCTFail()
        }
    }

#if os(macOS)
    func testPlistThatExistingNonRequiredIntValueHasRightValue() {
        thatExistingNonRequiredIntValueHasRightValue(.plistDictionary)
    }
#endif

    func testJSONThatExistingNonRequiredIntValueHasRightValue() {
        thatExistingNonRequiredIntValueHasRightValue(.jsonDictionary)
    }

    // MARK: Test `get` with string values
    
    func thatNonExistingNonRequiredStringValueIsNil(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let plist = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        XCTAssert(plist.get(varName: "NoStringHere") == nil)
    }

#if os(macOS)
    func testPlistThatNonExistingNonRequiredStringValueIsNil() {
        thatNonExistingNonRequiredStringValueIsNil(.plistDictionary)
    }
#endif

    func testJSONThatNonExistingNonRequiredStringValueIsNil() {
        thatNonExistingNonRequiredStringValueIsNil(.jsonDictionary)
    }
    
    func thatExistingNonRequiredStringValueHasRightValue(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        let result = config.get(varName: "MyString")
        
        XCTAssert(result != nil)
        
        if case .stringValue(let strResult) = result! {
            XCTAssert(strResult == "Hello World!")
        }
        else {
            XCTFail()
        }
    }

#if os(macOS)
    func testPlistThatExistingNonRequiredStringValueHasRightValue() {
        thatExistingNonRequiredStringValueHasRightValue(.plistDictionary)
    }
#endif

    func testJSONThatExistingNonRequiredStringValueHasRightValue() {
        thatExistingNonRequiredStringValueHasRightValue(.jsonDictionary)
    }
    
    // MARK: Test `getRequired` with integer values

    func thatNonExistingRequiredIntValueThrowsError(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        
        do {
            let _ = try config.getRequired(varName: "Foobar", ofType: .intType)
            XCTFail()
        } catch {
        }
    }
    
    // MARK: Test `getRequired` with boolean values
    
    func thatNonExistingRequiredBoolValueThrowsError(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
            
        do {
            let _ = try config.getRequired(varName: "Foobar", ofType: .boolType)
            XCTFail()
        } catch {
        }
    }

#if os(macOS)
    func testPlistThatNonExistingRequiredIntValueThrowsError() {
        thatNonExistingRequiredIntValueThrowsError(.plistDictionary)
    }
#endif

    func testJSONThatNonExistingRequiredIntValueThrowsError() {
        thatNonExistingRequiredIntValueThrowsError(.jsonDictionary)
    }
    
    func thatExistingRequiredIntValueHasRightValue(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        let result = try! config.getRequired(varName: "MyInteger", ofType: .intType)
        
        if case .intValue(let intResult) = result {
            XCTAssert(intResult == 100)
        }
        else {
            XCTFail()
        }
    }

#if os(macOS)
    func testPlistThatExistingRequiredIntValueHasRightValue() {
        thatExistingRequiredIntValueHasRightValue(.plistDictionary)
    }
#endif

    func testJSONThatExistingRequiredIntValueHasRightValue() {
        thatExistingRequiredIntValueHasRightValue(.jsonDictionary)
    }
    
#if os(macOS)
    func testPlistThatNonExistingRequiredBoolValueThrowsError() {
        thatNonExistingRequiredBoolValueThrowsError(.plistDictionary)
    }
#endif
    
    func testJSONThatNonExistingRequiredBoolValueThrowsError() {
        thatNonExistingRequiredBoolValueThrowsError(.jsonDictionary)
    }
    
    func thatExistingRequiredBoolValueHasRightValue(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        let result = try! config.getRequired(varName: "MyBool", ofType: .boolType)
        
        if case .boolValue(let boolResult) = result {
            XCTAssert(boolResult == false)
        }
        else {
            XCTFail()
        }
        
        let result2 = try! config.getRequired(varName: "MyBool2", ofType: .boolType)
        
        if case .boolValue(let boolResult) = result2 {
            XCTAssert(boolResult == true)
        }
        else {
            XCTFail()
        }
    }
    
#if os(macOS)
    func testPlistThatExistingRequiredBoolValueHasRightValue() {
        thatExistingRequiredBoolValueHasRightValue(.plistDictionary)
    }
#endif
    
    func testJSONThatExistingRequiredBoolValueHasRightValue() {
        thatExistingRequiredBoolValueHasRightValue(.jsonDictionary)
    }
    
    // MARK: Test `getRequired` with string values
    
    func thatNonExistingRequiredStringValueThrowsError(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        
        do {
            let _ = try config.getRequired(varName: "Foobar")
            XCTFail()
        } catch {
        }
    }

#if os(macOS)
    func testPlistThatNonExistingRequiredStringValueThrowsError() {
        thatNonExistingRequiredStringValueThrowsError(.plistDictionary)
    }
#endif

    func testJSONThatNonExistingRequiredStringValueThrowsError() {
        thatNonExistingRequiredStringValueThrowsError(.jsonDictionary)
    }

    func thatExistingRequiredStringValueHasRightValue(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        let result = try! config.getRequired(varName: "MyString")
        
        if case .stringValue(let strResult) = result {
            XCTAssert(strResult == "Hello World!")
        }
        else {
            XCTFail()
        }
    }

#if os(macOS)
    func testPlistThatExistingRequiredStringValueHasRightValue() {
        thatExistingRequiredStringValueHasRightValue(.plistDictionary)
    }
#endif

    func testJSONThatExistingRequiredStringValueHasRightValue() {
        thatExistingRequiredStringValueHasRightValue(.jsonDictionary)
    }
    
    // MARK: Test `getInt` with integer values

    func thatNonExistingGetIntValueThrowsError(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        
        do {
            let _ = try config.getInt(varName: "Foobar")
            XCTFail()
        } catch {
        }
    }
    
    func thatNonExistingGetBoolValueThrowsError(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        
        do {
            let _ = try config.getBool(varName: "Foobar")
            XCTFail()
        } catch {
        }
    }

#if os(macOS)
    func testPlistThatNonExistingGetIntIntValueThrowsError() {
        thatNonExistingGetIntValueThrowsError(.plistDictionary)
    }
#endif

    func testJSONThatNonExistingGetIntValueThrowsError() {
        thatNonExistingGetIntValueThrowsError(.jsonDictionary)
    }

    func thatExistingGetIntValueHasRightValue(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        let result = try! config.getInt(varName: "MyInteger")
        XCTAssert(result == 100)
    }

#if os(macOS)
    func testPlistThatExistingGetIntValueHasRightValue() {
        thatExistingGetIntValueHasRightValue(.plistDictionary)
    }
#endif

    func testJSONThatExistingGetIntValueHasRightValue() {
        thatExistingGetIntValueHasRightValue(.jsonDictionary)
    }
    
#if os(macOS)
    func testPlistThatNonExistingGetBoolValueThrowsError() {
        thatNonExistingGetBoolValueThrowsError(.plistDictionary)
    }
#endif
    
    func testJSONThatNonExistingGetBoolValueThrowsError() {
        thatNonExistingGetBoolValueThrowsError(.jsonDictionary)
    }
    
    func thatExistingGetBoolValueHasRightValue(_ configType:ConfigLoader.ConfigType) {
        let filename = fileForConfigType(configType)
        let config = try! ConfigLoader(usingPath: pathName, andFileName: filename, forConfigType: configType)
        let result = try! config.getBool(varName: "MyBool")
        XCTAssert(result == false)
    }
    
#if os(macOS)
    func testPlistThatExistingGetBoolValueHasRightValue() {
        thatExistingGetBoolValueHasRightValue(.plistDictionary)
    }
#endif
    
    func testJSONThatExistingGetBoolValueHasRightValue() {
        thatExistingGetBoolValueHasRightValue(.jsonDictionary)
    }
}

extension TestConfigLoader {
    static var allTests : [(String, (TestConfigLoader) -> () throws -> Void)] {
        return [
            ("testThatNonExistentJSONFileThrowsError",testThatNonExistentJSONFileThrowsError),
            ("testThatExistingJSONFileDoesNotThrowError",testThatExistingJSONFileDoesNotThrowError),
            ("testJSONThatNonExistingNonRequiredIntValueIsNotNil",testJSONThatNonExistingNonRequiredIntValueIsNotNil),
            ("testJSONThatExistingNonRequiredIntValueHasRightValue",testJSONThatExistingNonRequiredIntValueHasRightValue),
            ("testJSONThatNonExistingNonRequiredStringValueIsNil", testJSONThatNonExistingNonRequiredStringValueIsNil),
            ("testJSONThatExistingNonRequiredStringValueHasRightValue", testJSONThatExistingNonRequiredStringValueHasRightValue),
            ("testJSONThatNonExistingRequiredIntValueThrowsError", testJSONThatNonExistingRequiredIntValueThrowsError),
            ("testJSONThatExistingRequiredIntValueHasRightValue", testJSONThatExistingRequiredIntValueHasRightValue),
            ("testJSONThatNonExistingRequiredStringValueThrowsError", testJSONThatNonExistingRequiredStringValueThrowsError),
            ("testJSONThatExistingRequiredStringValueHasRightValue", testJSONThatExistingRequiredStringValueHasRightValue),
            ("testJSONThatNonExistingGetIntValueThrowsError",
                testJSONThatNonExistingGetIntValueThrowsError),
            ("testJSONThatExistingGetIntValueHasRightValue",
                testJSONThatExistingGetIntValueHasRightValue),
            ("testJSONThatNonExistingRequiredBoolValueThrowsError",
             testJSONThatNonExistingRequiredBoolValueThrowsError),
            ("testJSONThatExistingRequiredBoolValueHasRightValue",
             testJSONThatExistingRequiredBoolValueHasRightValue),
            ("testJSONThatNonExistingGetBoolValueThrowsError",
             testJSONThatNonExistingGetBoolValueThrowsError),
            ("testJSONThatExistingGetBoolValueHasRightValue",
             testJSONThatExistingGetBoolValueHasRightValue)
        ]
    }
}
