import Foundation
import SwiftUI
import PhotosUI
import Combine

class PhotoManager {
    static let shared = PhotoManager()
    
    private let photosDirectoryName = "PlantPhotos"
    
    private init() {
        createPhotosDirectoryIfNeeded()
    }
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var photosDirectory: URL {
        documentsDirectory.appendingPathComponent(photosDirectoryName)
    }
    
    private func createPhotosDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
    }
    
    func savePhoto(_ image: UIImage, for plantId: UUID) -> String? {
        let filename = "\(plantId.uuidString)_\(UUID().uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    func loadPhoto(filename: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    func getPhotoURL(filename: String) -> URL {
        photosDirectory.appendingPathComponent(filename)
    }
    
    func deletePhoto(filename: String) {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func deleteAllPhotos(for plant: Plant) {
        for photo in plant.photos {
            deletePhoto(filename: photo.filename)
        }
        
        if let coverFilename = plant.coverPhotoFilename {
            deletePhoto(filename: coverFilename)
        }
    }
    
    func createThumbnail(from image: UIImage, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func calculateStorageSize() -> String {
        var totalSize: Int64 = 0
        
        if let enumerator = FileManager.default.enumerator(at: photosDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

@MainActor
class ImagePickerCoordinator: NSObject, ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isPresented = false
    
    func reset() {
        selectedImage = nil
    }
}
