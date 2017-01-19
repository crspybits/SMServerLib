import PackageDescription

// Trying to figure out how to make this dependency test-only. See http://stackoverflow.com/questions/41401753/test-only-dependencies-when-using-the-swift-package-manger

let package = Package(
    name: "SMServerLib",
    dependencies: [
        // sudo apt-get install openssl libssl-dev uuid-dev
        //      is necessary on Linux to get this working
        .Package(url: "https://github.com/PerfectlySoft/Perfect.git", majorVersion: 2, minor: 0)
    ]
)
