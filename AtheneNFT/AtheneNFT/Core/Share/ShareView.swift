import SwiftUI
import PhotosUI

struct ShareView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = ShareViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create New NFT")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Image Selection Area
                    Group {
                        if let image = viewModel.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .onTapGesture {
                                    // Tap to change image
                                    viewModel.image = nil
                                }
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 300)
                                    .cornerRadius(12)
                                    
                                VStack(spacing: 12) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                    Text("Tap to select image")
                                }
                                .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Image Selection Options
                    HStack {
                        Spacer()
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Gallery", systemImage: "photo.on.rectangle")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        Button {
                            showCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    // Form fields
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .fontWeight(.semibold)
                        
                        TextField("Give your NFT a name", text: $viewModel.title)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $viewModel.description)
                            .frame(height: 100)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price (ETH)")
                            .fontWeight(.semibold)
                        
                        TextField("0.00", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Create button
                    Button {
                        viewModel.createNFT()
                    } label: {
                        if viewModel.isUploading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Uploading \(Int(viewModel.uploadProgress * 100))%")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            Text("Create NFT")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                    .disabled(viewModel.image == nil || viewModel.title.isEmpty || viewModel.isUploading)
                    .opacity((viewModel.image == nil || viewModel.title.isEmpty || viewModel.isUploading) ? 0.6 : 1.0)
                }
                .padding(.vertical)
            }
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
            .onChange(of: selectedItem) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.image = uiImage
                    }
                }
            }
            .alert(isPresented: $viewModel.successfullyCreated) {
                Alert(
                    title: Text("NFT Created"),
                    message: Text("Your NFT has been successfully created and listed."),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                    }
                )
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(selectedImage: $viewModel.image, isPresented: $showCamera)
            }
        }
    }
}