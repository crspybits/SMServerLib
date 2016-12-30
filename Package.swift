import PackageDescription

let package = Package(
    name: "SMServerLib",
    dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect.git", majorVersion: 2)
	]
)
