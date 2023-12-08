import SwiftUI

struct ContentView: View {
    @State private var error: Error?

    var body: some View {
        Image(.revenueCat)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200, alignment: .center)
            .padding(.bottom, 100)
            .task(loadAppData)
            .errorAlert(error: $error, action: {})
    }
    
    @Sendable private func loadAppData() async {
        do {
            _ = try await PurchaseService.default.products()
            //routeToNextPage()
        } catch {
            self.error = PurchaseError.retrievingPachasesError(error)
        }
    }
}

#Preview {
    ContentView()
}
