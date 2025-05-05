//
//  SetlistExportView.swift
//  BandSync
//

import SwiftUI
import PDFKit

struct SetlistExportView: View {
    let setlist: Setlist
    @State private var pdfData: Data?
    @State private var isExporting = false
    @State private var showShareSheet = false
    @State private var errorMessage: String?
    @State private var showBPM = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if let pdfData = pdfData, let pdfDocument = PDFDocument(data: pdfData) {
                PDFPreviewView(document: pdfDocument)
                    .padding()
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("PDF Preview")
                        .font(.title2)
                    
                    Text("Setlist: \(setlist.name)")
                        .font(.headline)
                    
                    Text("\(setlist.songs.count) songs • \(setlist.formattedTotalDuration)")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Spacer()
            
            // Option for BPM
            Toggle("Show BPM in export", isOn: $showBPM)
                .padding()
                .onChange(of: showBPM) { _ in
                    generatePDF()
                }
            
            // Action buttons
            VStack(spacing: 16) {
                Button {
                    generatePDF()
                } label: {
                    Label("Create PDF", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button {
                    showShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pdfData == nil ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(pdfData == nil)
            }
            .padding()
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Export Setlist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .overlay(Group {
            if isExporting {
                VStack {
                    ProgressView()
                    Text("Generating PDF...")
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        })
        .onAppear {
            generatePDF()
        }
        .sheet(isPresented: $showShareSheet) {
            if let pdfData = pdfData {
                DocumentShareSheet(items: [pdfData])
            }
        }
    }
    
    // PDF Generation with BPM option
    private func generatePDF() {
        isExporting = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            let generatedPDF = SetlistPDFExporter.export(setlist: self.setlist, showBPM: showBPM)
            
            DispatchQueue.main.async {
                isExporting = false
                
                if let pdf = generatedPDF {
                    pdfData = pdf
                } else {
                    errorMessage = "Failed to create PDF. Please try again."
                }
            }
        }
    }
}

// PDF Preview View
struct PDFPreviewView: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}
