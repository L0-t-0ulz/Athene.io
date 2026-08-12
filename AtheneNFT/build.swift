#!/usr/bin/swift

// Syntax-checks every Swift file in the project tree with `swiftc -parse`.
// This is NOT a real build (use `xcodebuild -scheme AtheneNFT build` for that);
// it's a fast standalone sanity check that every file at least parses.

import Foundation

print("Syntax-checking AtheneNFT Swift sources...")

// Get the current directory
let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
print("Current directory: \(currentDirectoryURL.path)")

// Find all Swift files
let enumerator = FileManager.default.enumerator(at: currentDirectoryURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])

var swiftFiles: [URL] = []

while let fileURL = enumerator?.nextObject() as? URL {
    if fileURL.pathExtension == "swift" && fileURL.lastPathComponent != "build.swift" {
        swiftFiles.append(fileURL)
    }
}

print("Found \(swiftFiles.count) Swift files")

var failures: [String] = []

for file in swiftFiles {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    process.arguments = ["swiftc", "-parse", file.path]
    let pipe = Pipe()
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus == 0 {
            print("✓ \(file.lastPathComponent)")
        } else {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            print("✗ \(file.lastPathComponent)")
            failures.append("\(file.lastPathComponent):\n\(output)")
        }
    } catch {
        failures.append("\(file.lastPathComponent): could not run swiftc (\(error))")
    }
}

if failures.isEmpty {
    print("All \(swiftFiles.count) files parse cleanly")
} else {
    print("\n\(failures.count) file(s) failed to parse:")
    for failure in failures {
        print(failure)
    }
    exit(1)
}
