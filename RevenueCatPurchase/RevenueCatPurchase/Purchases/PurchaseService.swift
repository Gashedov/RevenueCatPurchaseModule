import Combine
import RevenueCat

final class PurchaseService {
    static let `default` = PurchaseService()
    
    var subscriptionIsActive: Bool = false
    var retrievedPackages: [PurchasesPackage] = []
    var offerings: Offerings? = nil
    
    let retrievedPackagesSubject = PassthroughSubject<Result<[PurchasesPackage], PurchaseError>, Never>()
    let receiptVerifiedSubject = PassthroughSubject<Result<String, PurchaseError>, Never>()
    
    private init() {
#if DEBUG
        Purchases.logLevel = .debug
#endif
        Purchases.configure(withAPIKey: "RevenueCatKey")
    }
    
    /// Fetches package from list of retrieved.
    /// Index here is basically a lifetime priority of a package
    /// Index == 0 means that function will return package with the longes lifetime duration
    ///
    /// - Parameters:
    ///   - withIndex: The index of package in list of available.
    ///     Remember that packages are stored in desceding order of their lifetime duration
    func fetchAvailablePackage(withIndex index: Int) -> PurchasesPackage? {
        guard retrievedPackages.count > index else { return nil }
        return retrievedPackages[index]
    }
    
    /// Performs purchase call for package under given index from list of retrieved.
    /// Index here is basically a lifetime priority of a package
    /// Index == 0 means that function will try to purchase package with the longes lifetime duration
    ///
    /// - Parameters:
    ///   - withIndex: The index of package in list of available.
    ///     Remember that packages are stored in desceding order of their lifetime duration
    func purchaseSubscription(withIndex index: Int) {
        guard let package = fetchAvailablePackage(withIndex: index) else {
            print("Package with index \(index) doesn't exist in current offering")
            return
        }
        purchaseSubscription(package)
    }
    
    /// Performs purchase call for package using wrapped package instance
    ///
    /// - Parameters:
    ///   - package: RevenueCat package wrapped in PurchasePackege instance.
    func purchaseSubscription(_ package: PurchasesPackage) {
        purchaseSubscription(package.package)
    }
    
    /// Performs purchase call for package
    func purchaseSubscription(_ package: Package) {
        print("Trying to purchase package: \(package)")
        Purchases.shared.purchase(
            package: package
        ) { [weak self] transaction, customerInfo, error, userCancelled in
            self?.verifyStoreSubscriptionInfo(customerInfo: customerInfo, error: error)
        }
    }
    
    
    func restorePurchases() {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            self?.verifyStoreSubscriptionInfo(customerInfo: customerInfo, error: error)
        }
    }
    
    /// Loads all available revenueCat packages from API service
    /// Please be carefull - this function saves packages only from RevenueCat Current Offering
    ///
    func loadProducts() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            if let error {
                print("Getting offers error: \(error.localizedDescription)")
                self?.retrievedPackagesSubject.send(.failure(.retrievingPachasesError(error)))
            }
            if let currentOffering = offerings?.current,
               let packeges = self?.retieveRevenueCatPackages(from: currentOffering) {
                self?.retrievedPackages = packeges
                self?.offerings = offerings
                self?.retrievedPackagesSubject.send(.success(packeges))
                print("💰✅ Successfully loaded RevenueCat packeges with products: \(packeges.map { $0.package.storeProduct.productIdentifier } )")
            }
        }
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            self?.verifyStoreSubscriptionInfo(customerInfo: customerInfo, error: error)
        }
    }
    
    /// Verifies subsrption info via checking customerInfo.entitlements.active.isActive
    /// And emits result to receiptVerifiedSubject
    private func verifyStoreSubscriptionInfo(customerInfo: CustomerInfo?, error: Error?) {
        if let error {
            receiptVerifiedSubject.send(.failure(.getCustomerInfoError(error)))
            print("error occured: \(error.localizedDescription)")
            return
        }
        var isSubscribed = false
        if let customerInfo {
            isSubscribed = !customerInfo.entitlements.active.isEmpty
            print("Verifying store subscription info: \(customerInfo.entitlements)")
            if isSubscribed {
                subscriptionIsActive = true
                receiptVerifiedSubject.send(.success(""))
            } else {
                receiptVerifiedSubject.send(.failure(.purcheseNotVerified))
            }

            print("💰✅ CHECK BOX IT's \(isSubscribed ? "PRO NOW" : "NOT PRO NOW")")
        }
    }
    
    /// Retrieves all purchase packeges from offering and collect it into array in desceding order
    func retieveRevenueCatPackages(from offering: Offering) -> [PurchasesPackage] {
        var result: [PurchasesPackage] = []
        if let lifetime = offering.lifetime {
            result.append(.init(package: lifetime, type: .lifeTime))
        }
        if let annual = offering.annual {
            result.append(.init(package: annual, type: .annual))
        }
        if let sixMonth = offering.sixMonth {
            result.append(.init(package: sixMonth, type: .sixMonths))
        }
        if let threeMonth = offering.threeMonth {
            result.append(.init(package: threeMonth, type: .threeMonths))
        }
        if let twoMonth = offering.twoMonth {
            result.append(.init(package: twoMonth, type: .twoMonths))
        }
        if let monthly = offering.monthly {
            result.append(.init(package: monthly, type: .monthly))
        }
        if let weekly = offering.weekly {
            result.append(.init(package: weekly, type: .weekly))
        }
        return result.sorted(by: >)
    }
}
