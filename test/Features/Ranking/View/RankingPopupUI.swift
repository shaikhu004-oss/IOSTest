import SwiftUI

// MARK: - 1. API Response & Currency Model
struct ExchangeRateResponse: Codable {
    let base: String
    let rates: [String: Double]
}

struct Currency: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let symbol: String
    let rate: Double
    
    func format(value: Int) -> String {
        if self.code == "USD" { return "$\(value)" }
        let converted = Double(value) * rate
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: converted)) ?? "\(Int(converted))"
        return "\(symbol)\(formatted)"
    }
    
    static let usd = Currency(name: "US Dollar", code: "USD", symbol: "$", rate: 1.0)
}

// MARK: - 2. Self-Loading Centered Popup View
struct CurrencyPopupView: View {
    @Binding var selectedCurrency: Currency
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @State private var fetchedCurrencies: [Currency] = [.usd]
    @State private var isLoading = true
    
    let themeGreen = Color(red: 0.0, green: 1.0, blue: 0.5)
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty { return fetchedCurrencies }
        return fetchedCurrencies.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }
            
            VStack(spacing: 0) {
                Text("choose_currency")
                    .font(.custom("ClashDisplay-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("", text: $searchText, prompt: Text("search_currency").foregroundColor(.gray))
                        .foregroundColor(.white)
                        .accentColor(themeGreen)
                }
                .padding(14)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if isLoading {
                            ProgressView()
                                .tint(themeGreen)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 20)
                        } else {
                            ForEach(filteredCurrencies) { currency in
                                Button(action: {
                                    selectedCurrency = currency
                                    withAnimation { isPresented = false }
                                }) {
                                    HStack {
                                        Text(currency.name)
                                            .font(.custom("ClashDisplay-Medium", size: 16))
                                            .foregroundColor(.white)
                                        Spacer()
                                        if selectedCurrency.code == currency.code {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(themeGreen)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: 320, maxHeight: 450)
            .background(Color(red: 0.07, green: 0.08, blue: 0.07))
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
        .zIndex(2)
        .task {
            guard let url = URL(string: "https://api.exchangerate-api.com/v4/latest/USD") else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let response = try? JSONDecoder().decode(ExchangeRateResponse.self, from: data) {
                    var newCurrencies: [Currency] = []
                    
                    // 🛠️ FIX: Force standard English Locale to guarantee human-readable names (e.g. "Chilean Peso")
                    let englishLocale = Locale(identifier: "en_US")
                    
                    for (code, rate) in response.rates {
                        let symbolLocale = NSLocale(localeIdentifier: code)
                        let symbol = symbolLocale.displayName(forKey: .currencySymbol, value: code) ?? code
                        let name = englishLocale.localizedString(forCurrencyCode: code) ?? code
                        
                        newCurrencies.append(Currency(name: name, code: code, symbol: symbol, rate: rate))
                    }
                    
                    let sorted = newCurrencies.sorted { $0.name < $1.name }
                    var finalCurrencies = sorted.filter { $0.code != "USD" }
                    finalCurrencies.insert(.usd, at: 0)
                    
                    await MainActor.run {
                        self.fetchedCurrencies = finalCurrencies
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

// 🛠️ Shared grouping struct
struct GroupedReward: Identifiable {
    let id = UUID()
    let rankText: String
    let value: Int
}

// MARK: - 3. Beats Rewards View
struct BeatsRewardsView: View {
    @Binding var isPresented: Bool
    var rewards: [RewardTier]
    
    @State private var selectedCurrency: Currency = .usd
    @State private var showCurrencyPopup = false
    
    let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    let themeGreen = Color(red: 0.0, green: 1.0, blue: 0.5)
    
    var totalAmount: String {
        let sum = rewards.reduce(0) { $0 + $1.value }
        return "$\(sum)"
    }
    
    var groupedRewards: [GroupedReward] {
        guard !rewards.isEmpty else { return [] }
        let sorted = rewards.sorted(by: { $0.rank < $1.rank })
        var result: [GroupedReward] = []
        var startRank = sorted[0].rank
        var endRank = sorted[0].rank
        var currentValue = sorted[0].value
        
        for i in 1..<sorted.count {
            let current = sorted[i]
            if current.value == currentValue && current.rank == endRank + 1 {
                endRank = current.rank
            } else {
                let rankStr = (startRank == endRank) ? "\(startRank)" : "\(startRank) - \(endRank)"
                result.append(GroupedReward(rankText: rankStr, value: currentValue))
                startRank = current.rank
                endRank = current.rank
                currentValue = current.value
            }
        }
        let rankStr = (startRank == endRank) ? "\(startRank)" : "\(startRank) - \(endRank)"
        result.append(GroupedReward(rankText: rankStr, value: currentValue))
        return result
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut) { isPresented = false }
                }
            
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Beats Rewards")
                            .font(.custom("ClashDisplay-Bold", size: 22))
                            .foregroundColor(.white)
                        
                        Text("Earn rewards every 7 days by collecting the most data points (Beats).")
                            .font(.system(size: 14))
                            .foregroundColor(themeGreen)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Button(action: {
                        withAnimation(.easeInOut) { isPresented = false }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                    }
                }
                .padding(.bottom, 24)
                
                HStack {
                    Text("Total")
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(.white)
                    Spacer()
                    Text(totalAmount)
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(themeGreen)
                    Spacer()
                    Text(selectedCurrency.format(value: rewards.reduce(0) { $0 + $1.value }))
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(themeGreen)
                }
                .padding(20)
                .background(themeBlack)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeGreen.opacity(0.4), lineWidth: 1))
                .padding(.bottom, 24)
                
                HStack {
                    Text("Rank")
                        .frame(width: 60, alignment: .leading)
                    Spacer()
                    Text("USD")
                        .frame(width: 80, alignment: .trailing)
                    Spacer()
                    Button(action: { withAnimation { showCurrencyPopup = true } }) {
                        HStack(spacing: 4) {
                            // 🛠️ FIX: Shows "EUR", "CLP", etc in the header to perfectly match your "USD" design
                            Text(selectedCurrency.code)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .frame(width: 80, alignment: .trailing)
                    }
                }
                .font(.custom("ClashDisplay-Bold", size: 16))
                .foregroundColor(themeGreen)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(groupedRewards) { group in
                            RewardRow(
                                rank: group.rankText,
                                amount: "$\(group.value)",
                                convertedAmount: selectedCurrency.format(value: group.value),
                                themeGreen: themeGreen
                            )
                        }
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: 350)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 24)
            .background(Color(red: 0.07, green: 0.08, blue: 0.07))
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            if showCurrencyPopup {
                CurrencyPopupView(selectedCurrency: $selectedCurrency, isPresented: $showCurrencyPopup)
            }
        }
    }
}

// Reusable Row Component
struct RewardRow: View {
    let rank: String
    let amount: String
    let convertedAmount: String
    let themeGreen: Color
    
    var body: some View {
        HStack {
            Text(rank)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            Spacer()
            Text(amount)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(themeGreen)
                .frame(width: 80, alignment: .trailing)
            Spacer()
            Text(convertedAmount)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(themeGreen)
                .frame(width: 80, alignment: .trailing)
        }
    }
}
