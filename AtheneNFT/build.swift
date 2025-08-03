#!/usr/bin/swift

import Foundation

print("Building AtheneNFT project...")

// Get the current directory
let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
print("Current directory: \(currentDirectoryURL.path)")

// Find all Swift files
let enumerator = FileManager.default.enumerator(at: currentDirectoryURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])

var swiftFiles: [URL] = []

while let fileURL = enumerator?.nextObject() as? URL {
    if fileURL.pathExtension == "swift" {
        swiftFiles.append(fileURL)
    }
}

print("Found \(swiftFiles.count) Swift files")

// Print the list of Swift files
for file in swiftFiles {
    print("- \(file.lastPathComponent)")
}

print("Build script completed successfully") 