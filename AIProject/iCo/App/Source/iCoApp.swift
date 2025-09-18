//
//  AIProjectApp.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct iCoApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var themeManager = ThemeManager()
    @StateObject private var recommendCoinViewModel = RecommendCoinViewModel()
    @State private var coinStore: CoinStore = .init(
        coinService: DefaultCoinService(network: NetworkClient())
    )

    @State private var connectivity = ConnectivityMonitor()
    @State private var appManager: AppConnectivityManager!

    private let coinService: UpBitAPIService = UpBitAPIService()
    private let tickerService: RealTimeTickerProvider = UpbitTickerService()

    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    SplashScreenView(isLoading: $isLoading)
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .opacity.animation(.easeOut(duration: 0.3))
                        ))
                        .zIndex(1)
                        .environmentObject(recommendCoinViewModel)
                } else {
                    if hasSeenOnboarding {
                        MainTabView(
                            tickerService: tickerService,
                            coinService: coinService
                        )
                        .safeAreaInset(edge: .top, content: {
                            TopBannerView(controller: appManager.banner)
                                .animation(.snappy, value: appManager.banner.isVisible)
                        })
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(themeManager)
                        .environmentObject(recommendCoinViewModel)
                    } else {
                        OnboardingView()
                            .environmentObject(recommendCoinViewModel)
                    }
                }
            }
            .environment(coinStore)
            .onAppear {
                if appManager == nil {
                    appManager = AppConnectivityManager(connectivity: connectivity)
                }
            }
        }
    }
}

struct SplashScreenView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @Binding var isLoading: Bool
    @EnvironmentObject var recommendCoinViewModel: RecommendCoinViewModel
    @Environment(CoinStore.self) var coinStore

    var body: some View {
        ZStack {
            Image("launchscreen-bg")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
        }
        .task {
            if hasSeenOnboarding { recommendCoinViewModel.loadRecommendCoin() }
            Task { await coinStore.loadCoins() }
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
