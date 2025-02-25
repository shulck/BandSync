import SwiftUI

struct FinanceView: View {
    @StateObject private var viewModel = FinanceViewModel()
    
    var body: some View {
        List {
            Section(header: Text("Summary")) {
                HStack {
                    Text("Total Income:")
                    Spacer()
                    Text("$\(viewModel.totalIncome, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Total Expenses:")
                    Spacer()
                    Text("$\(viewModel.totalExpenses, specifier: "%.2f")")
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("Balance:")
                    Spacer()
                    Text("$\(viewModel.balance, specifier: "%.2f")")
                        .foregroundColor(viewModel.balance >= 0 ? .green : .red)
                }
            }
            
            Section(header: Text("Transactions")) {
                ForEach(viewModel.transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
                .onDelete(perform: viewModel.deleteTransaction)
            }
        }
        .navigationTitle("Finances")
        .toolbar {
            Button(action: { viewModel.showingAddTransaction.toggle() }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $viewModel.showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
    }
}

struct TransactionRowView: View {
    let transaction: FinanceViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.details ?? "")
                    .font(.headline)
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(transaction.amount, specifier: "%.2f")")
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
    }
}
