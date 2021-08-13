import Foundation
import PathLib
import Tmp

func createTestDataForEnumeration(tempFolder: TemporaryFolder) throws -> Set<AbsolutePath> {
    return Set([
        try tempFolder.createFile(filename: "root_file"),
        try tempFolder.createDirectory(components: ["empty_folder"]),
        try tempFolder.createDirectory(components: ["subfolder"]),
        try tempFolder.createFile(components: ["subfolder"], filename: "file_in_subfolder")
    ])
}
