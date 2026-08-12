import SwiftUI

struct NFTTransferDetailView: View {
    @Binding var isPresented: Bool
    let selectedWallet: WalletType
    @State private var selectedNFT: Int?
    @State private var recipientAddress = ""
    @State private var showingTransferConfirmation = false
    @State private var isTransferring = false

    /// Basic EVM address shape: 0x + 40 hex characters.
    private var isAddressValid: Bool {
        recipientAddress.hasPrefix("0x")
            && recipientAddress.count == 42
            && recipientAddress.dropFirst(2).allSatisfy { $0.isHexDigit }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Selected Wallet Info
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .frame(width: 48, height: 48)
                            
                            // Display wallet icon
                            getWalletIcon(for: selectedWallet)
                                .frame(width: 30, height: 30)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Transfer to")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(selectedWallet.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // NFT Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select NFT to Transfer")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<6) { index in
                                    NFTSelectionCard(
                                        index: index,
                                        isSelected: selectedNFT == index,
                                        action: {
                                            selectedNFT = index
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recipient Address
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recipient Address")
                            .font(.headline)
                        
                        Text("Enter the wallet address to transfer this NFT")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("0x...", text: $recipientAddress)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        if !recipientAddress.isEmpty && !isAddressValid {
                            Text("Enter a valid address: 0x followed by 40 hex characters.")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Gas Fee Info
                    VStack(spacing: 12) {
                        HStack {
                            Text("Network Fee")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("~0.002 ETH")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Estimated Time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("~2 minutes")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Transfer Button
                    Button(action: {
                        if selectedNFT != nil && isAddressValid {
                            showingTransferConfirmation = true
                        }
                    }) {
                        if isTransferring {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Transferring...")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        } else {
                            Text("Transfer NFT")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedNFT != nil && isAddressValid ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                    .disabled(selectedNFT == nil || !isAddressValid || isTransferring)
                    .padding(.horizontal)
                    
                    // Warning
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Double-check the recipient address. Transfers cannot be reversed.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Transfer NFT")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
            .alert(isPresented: $showingTransferConfirmation) {
                Alert(
                    title: Text("Confirm Transfer"),
                    message: Text("Transfer NFT #\(selectedNFT ?? 0) to \(String(recipientAddress.prefix(6)))...\(String(recipientAddress.suffix(4)))?"),
                    primaryButton: .destructive(Text("Transfer")) {
                        performTransfer()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func performTransfer() {
        isTransferring = true

        // Simulate transfer
        DispatchQueue.main.asyncAfter(deadline: .now() + MockLatency.transfer) {
            isTransferring = false
            isPresented = false
        }
    }
    
    // Helper function to get wallet icon view
    @ViewBuilder
    func getWalletIcon(for wallet: WalletType) -> some View {
        switch wallet {
        case .metamask:
            Image(systemName: "fox")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.orange)
        case .bitski:
            Image(systemName: "diamond.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.purple)
        case .fortmatic:
            Text("F")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.blue)
        case .walletConnect:
            Image(systemName: "link")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
        default:
            Text(String(wallet.name.prefix(1)))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.gray)
        }
    }
}

struct NFTSelectionCard: View {
    let index: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .cornerRadius(12)
                    .overlay(
                        Text("NFT #\(index)")
                            .font(.headline)
                            .foregroundColor(.gray)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                
                Text("NFT #\(index)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("0.\(index) ETH")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}