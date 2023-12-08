import RevenueCat

// Async version of service functions
extension PurchaseService {
    func products(retryCount: Int = 10) async throws -> [PurchaseService.PurchasesPackage] {
        if !retrievedPackages.isEmpty {
            return retrievedPackages
        }
        
        let retrievedOfferings = try await Task.retrying(maxRetryCount: retryCount) {
            return try await Purchases.shared.offerings()
        }.value
        
        guard let currentOffering = retrievedOfferings.current else { throw PurchaseError.currentOfferingNotFound }
        let packeges = retieveRevenueCatPackages(from: currentOffering)
        retrievedPackages = packeges
        offerings = retrievedOfferings
        print("💰✅ Successfully loaded RevenueCat packeges with products: \(packeges.map { $0.package.storeProduct.productIdentifier } )")
        return packeges
    }
    
    func purchaseSubscription(_ package: PurchasesPackage) async throws {
        try await purchaseSubscription(package.package)
    }
    
    func purchaseSubscription(_ package: Package) async throws {
        print("Trying to purchase package: \(package)")
        let purchaseData = try await Purchases.shared.purchase(package: package)
        try verifyStoreSubscriptionInfo(purchaseData.customerInfo)
    }
    
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        try verifyStoreSubscriptionInfo(customerInfo)
    }
    
    func checkSubscriptionStatus() async throws -> Bool {
        let customerInfo = try await Purchases.shared.customerInfo()
        try verifyStoreSubscriptionInfo(customerInfo)
        return true
    }
    
    private func verifyStoreSubscriptionInfo(_ customerInfo: CustomerInfo) throws {
        let isSubscribed = !customerInfo.entitlements.active.isEmpty
        print("Verifying store subscription info: \(customerInfo.entitlements)")
        if !isSubscribed {
            throw PurchaseError.purcheseNotVerified
        }
        print("💰✅ CHECK BOX IT's \(isSubscribed ? "PRO NOW" : "NOT PRO NOW")")
    }
}
