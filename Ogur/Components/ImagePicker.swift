import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PhotoSourcePicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @State private var showImagePicker = false
    @State private var showCamera = false
    
    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add Photo")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 0) {
                if isCameraAvailable {
                    Button {
                        showCamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Take Photo")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    Divider()
                        .padding(.leading, 56)
                }
                
                Button {
                    showImagePicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Choose from Gallery")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .onChange(of: selectedImage) { _, _ in
            if selectedImage != nil {
                isPresented = false
            }
        }
    }
}

struct PhotoGridView: View {
    let photos: [PhotoRecord]
    let onTap: (PhotoRecord) -> Void
    let onDelete: ((PhotoRecord) -> Void)?
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos) { photo in
                PhotoThumbnail(photo: photo)
                    .onTapGesture { onTap(photo) }
                    .contextMenu {
                        if let onDelete = onDelete {
                            Button(role: .destructive) {
                                onDelete(photo)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
            }
        }
    }
}

struct PhotoThumbnail: View {
    let photo: PhotoRecord
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            image = PhotoManager.shared.loadPhoto(filename: photo.filename)
        }
    }
}
