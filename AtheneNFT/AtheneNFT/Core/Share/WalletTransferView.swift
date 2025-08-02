import SwiftUI

struct WalletTransferView: View {
    @Binding var isPresented: Bool
    @State private var selectedWallet: WalletType?
    @State private var showMoreOptions = false
    @State private var showTransferDetail = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Modal content
            VStack(spacing: 0) {
                // Header
                HStack {
                    // Wallet icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                    
                    Text("Select a Wallet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .padding()
                .background(Color.white)
                
                Divider()
                
                // Instructions text
                Text("Please select a wallet to connect to this dapp:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                
                Divider()
                
                // Wallet options
                VStack(spacing: 0) {
                    WalletOptionRow(
                        wallet: .metamask,
                        isSelected: selectedWallet == .metamask,
                        action: { selectWallet(.metamask) }
                    )
                    
                    Divider()
                    
                    WalletOptionRow(
                        wallet: .bitski,
                        isSelected: selectedWallet == .bitski,
                        action: { selectWallet(.bitski) }
                    )
                    
                    Divider()
                    
                    WalletOptionRow(
                        wallet: .fortmatic,
                        isSelected: selectedWallet == .fortmatic,
                        action: { selectWallet(.fortmatic) }
                    )
                    
                    Divider()
                    
                    WalletOptionRow(
                        wallet: .walletConnect,
                        isSelected: selectedWallet == .walletConnect,
                        action: { selectWallet(.walletConnect) }
                    )
                    
                    Divider()
                    
                    // Show More Options button
                    Button(action: {
                        withAnimation {
                            showMoreOptions = true
                        }
                    }) {
                        Text("Show More Options")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 10)
            .padding(.horizontal, 20)
            .frame(maxWidth: 400)
            .sheet(isPresented: $showTransferDetail) {
                if let wallet = selectedWallet {
                    NFTTransferDetailView(isPresented: $showTransferDetail, selectedWallet: wallet)
                }
            }
        }
    }
    
    func selectWallet(_ wallet: WalletType) {
        selectedWallet = wallet
        // Simulate connection and show next screen after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showTransferDetail = true
        }
    }
}

struct WalletOptionRow: View {
    let wallet: WalletType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Wallet icon
                wallet.icon
                    .padding(.trailing, 12)
                
                // Wallet name
                Text(wallet.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
        }
    }
}

enum WalletType: String, CaseIterable {
    case metamask = "MetaMask Mobile"
    case bitski = "Bitski"
    case fortmatic = "Fortmatic"
    case walletConnect = "WalletConnect"
    case trustWallet = "Trust Wallet"
    case rainbow = "Rainbow"
    case argent = "Argent"
    case coinbase = "Coinbase Wallet"
    
    var name: String {
        return self.rawValue
    }
    
    var icon: some View {
        Group {
            switch self {
            case .metamask:
                Image("metamask-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .background(Color.white)
            case .bitski:
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Image(systemName: "diamond.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.purple)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            case .fortmatic:
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Text("F")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.blue)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            case .walletConnect:
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Image(systemName: "link")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.blue)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            default:
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                    Text(String(name.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

struct WalletTransferView_Previews: PreviewProvider {
    static var previews: some View {
        WalletTransferView(isPresented: .constant(true))
    }
}