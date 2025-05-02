import SwiftUI
import VisionKit

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var type: FinanceType = .expense
    @State private var category: FinanceCategory = .logistics
    @State private var amount: String = ""
    @State private var currency: String = "EUR"
    @State private var details: String = ""
    @State private var date = Date()

    @State private var showReceiptScanner = false
    @State private var scannedText = ""
    @State private var extractedFinanceRecord: FinanceRecord?
    @State private var recognizedItems: [ReceiptItem] = []
    @State private var isLoadingTransaction = false

    private var isAmountValid: Bool {
        guard !amount.isEmpty else { return true }
        return Double(amount.replacingOccurrences(of: ",", with: ".")) != nil
    }

    private var formIsValid: Bool {
        return isAmountValid &&
               (!amount.isEmpty || extractedFinanceRecord != nil) &&
               !currency.isEmpty
    }

    private var currencies = ["EUR", "USD", "RUB"]

    var body: some View {
        NavigationView {
            Form {
                // Transaction Type Picker
                Section {
                    Picker(NSLocalizedString("type", comment: ""), selection: $type) {
                        Text(NSLocalizedString("income", comment: "")).tag(FinanceType.income)
                        Text(NSLocalizedString("expense", comment: "")).tag(FinanceType.expense)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) { newType in
                        category = FinanceCategory.forType(newType).first ?? .logistics
                    }
                }

                // Category Picker
                Section {
                    Picker(NSLocalizedString("category", comment: ""), selection: $category) {
                        ForEach(FinanceCategory.forType(type)) { cat in
                            HStack {
                                Image(systemName: categoryIcon(for: cat))
                                    .foregroundColor(categoryColor(for: cat))
                                Text(NSLocalizedString(cat.rawValue, comment: ""))
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Input Fields
                Section {
                    HStack {
                        TextField(NSLocalizedString("amount", comment: ""), text: $amount)
                            .keyboardType(.decimalPad)

                        Picker(NSLocalizedString("currency", comment: ""), selection: $currency) {
                            ForEach(currencies, id: \.self) { curr in
                                Text(curr).tag(curr)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 80)
                    }

                    if !isAmountValid {
                        Text(NSLocalizedString("invalid_amount", comment: ""))
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    TextField(NSLocalizedString("details", comment: ""), text: $details)

                    DatePicker(NSLocalizedString("date", comment: ""), selection: $date, displayedComponents: [.date])
                }

                // Receipt Scanner Button
                Section {
                    Button(action: {
                        showReceiptScanner = true
                    }) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("scan_receipt", comment: ""))
                        }
                    }
                }

                // Scanned Text Display
                if !scannedText.isEmpty {
                    Section(header: Text(NSLocalizedString("receipt_text", comment: ""))) {
                        Text(scannedText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Display Extracted Record
                if let record = extractedFinanceRecord {
                    Section(header: Text(NSLocalizedString("recognized_data", comment: ""))) {
                        HStack {
                            Text(NSLocalizedString("amount", comment: ""))
                            Spacer()
                            Text("\(String(format: "%.2f", record.amount)) \(record.currency)")
                                .foregroundColor(record.type == .income ? .green : .red)
                        }

                        HStack {
                            Text(NSLocalizedString("category", comment: ""))
                            Spacer()
                            Text(NSLocalizedString(record.category, comment: ""))
                        }

                        HStack {
                            Text(NSLocalizedString("date", comment: ""))
                            Spacer()
                            Text(formattedDate(record.date))
                        }

                        Button(action: {
                            amount = String(format: "%.2f", record.amount)
                            currency = record.currency
                            type = record.type
                            date = record.date
                            details = record.details

                            if let cat = FinanceCategory.allCases.first(where: { $0.rawValue == record.category }) {
                                category = cat
                            }
                        }) {
                            Label(NSLocalizedString("use_data", comment: ""), systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("new_record", comment: ""))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save", comment: "")) {
                        isLoadingTransaction = true
                        saveRecord()
                    }
                    .disabled(!formIsValid || isLoadingTransaction)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isLoadingTransaction {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView(NSLocalizedString("saving", comment: ""))
                        .padding()
                        .background(Color.systemBackground)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .sheet(isPresented: $showReceiptScanner) {
                ReceiptScannerView(
                    recognizedText: $scannedText,
                    extractedFinanceRecord: $extractedFinanceRecord
                )
            }
        }
    }

    private func saveRecord() {
        guard let groupId = AppState.shared.user?.groupId else { return }

        let recordToSave: FinanceRecord

        if let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")), !amount.isEmpty {
            recordToSave = FinanceRecord(
                type: type,
                amount: amountValue,
                currency: currency.uppercased(),
                category: category.rawValue,
                details: details,
                date: date,
                receiptUrl: nil,
                groupId: groupId
            )
        } else if let extractedRecord = extractedFinanceRecord {
            recordToSave = extractedRecord
        } else {
            isLoadingTransaction = false
            return
        }

        guard recordToSave.amount > 0 && !recordToSave.currency.isEmpty else {
            isLoadingTransaction = false
            return
        }

        FinanceService.shared.add(recordToSave) { success in
            isLoadingTransaction = false
            if success {
                OfflineFinanceManager.shared.cacheRecord(recordToSave)
                dismiss()
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func categoryIcon(for category: FinanceCategory) -> String {
        switch category {
        case .logistics: return "car.fill"
        case .food: return "fork.knife"
        case .gear: return "guitars"
        case .promo: return "megaphone.fill"
        case .other: return "ellipsis.circle.fill"
        case .performance: return "music.note"
        case .merch: return "tshirt.fill"
        case .accommodation: return "house.fill"
        case .royalties: return "music.quarternote.3"
        case .sponsorship: return "dollarsign.circle"
        }
    }

    private func categoryColor(for category: FinanceCategory) -> Color {
        switch category {
        case .logistics: return .blue
        case .food: return .orange
        case .gear: return .purple
        case .promo: return .green
        case .other: return .secondary
        case .performance: return .red
        case .merch: return .indigo
        case .accommodation: return .teal
        case .royalties: return .purple
        case .sponsorship: return .green
        }
    }
}

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
}
