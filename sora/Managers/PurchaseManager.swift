//
//  PurchaseManager.swift
//  sora
//
//  Created by Elias CHETOUANI on 01/05/2024.
//

//import Foundation
import StoreKit


@MainActor
class PurchaseManager: ObservableObject {
    
    private let productIds = ["monthly", "weekly_free_trial"]
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    var hasUnlockedPro: Bool { !self.purchasedProductIDs.isEmpty }
    private var updates: Task<Void, Never>? = nil
    init() { updates = observeTransactionUpdates() }
    deinit { updates?.cancel() }
    
    private var productsLoaded = false
    
    
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            print("purchase success")
            await transaction.finish()
            await self.updatePurchasedProducts()
            
        case .success(.unverified(_, _)): //second one is used for error
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            print("purchase unverified")
            break
        case .pending:
            print("purchase pending")
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            print("purchase cancelled")
            // ^^^
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            

            if let expiryDate = transaction.expirationDate, expiryDate > Date() {
                     // Insert ID if the subscription is still valid
                     self.purchasedProductIDs.insert(transaction.productID)
                 } else {
                     // Remove ID if the subscription has expired or is no longer valid
                     self.purchasedProductIDs.remove(transaction.productID)
                 }
        }
    }
    
    
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ /*verificationResult*/ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}
