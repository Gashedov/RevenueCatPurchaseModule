import Foundation

enum PurchaseError: LocalizedError {
    case purcheseNotVerified
    case getCustomerInfoError(Error)
    case retrievingPachasesError(Error)
    case currentOfferingNotFound
}

extension PurchaseError {
    var errorDescription: String? {
        switch self {
        case .purcheseNotVerified: return "Purchese not verified"
        case .getCustomerInfoError(let error): return error.localizedDescription
        case .retrievingPachasesError: return "Purchase products couldn't be fetched.\nPlease check your internet connection and try again"
        case .currentOfferingNotFound: return "Current offering not found"
        }
    }
}
