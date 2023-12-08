import RevenueCat

extension PurchaseService {
    // This revenueCar packege wrapper helps identify and sort packege by its lifetime duration
    struct PurchasesPackage: Comparable {
        enum King: Int, Comparable {
            case weekly
            case monthly
            case twoMonths
            case threeMonths
            case sixMonths
            case annual
            case lifeTime
            
            static func < (
                lhs: PurchaseService.PurchasesPackage.King,
                rhs: PurchaseService.PurchasesPackage.King
            ) -> Bool {
                lhs.rawValue < rhs.rawValue
            }
        }
        let package: Package
        let type: King
        
        static func < (
            lhs: PurchaseService.PurchasesPackage,
            rhs: PurchaseService.PurchasesPackage
        ) -> Bool {
            lhs.type < rhs.type
        }
    }
}
