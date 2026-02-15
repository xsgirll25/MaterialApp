//
//  MaterialRequestForm.swift
//  MaterialOrderApp
//
//  Created by xsyoulia on 18.09.2025.
//
internal import SwiftUI

struct DemoRequestForm: View {
        @StateObject private var storageManager = LocalStorageManager()
        
        @State private var workerName: String = ""
        @State private var department: String = ""
        @State private var selectedMaterialType: BuildingMaterial = .cement
        @State private var materialName: String = ""
        @State private var quantityString: String = ""
        @State private var unit: String = "шт"
        @State private var selectedUrgency: MaterialRequest.UrgencyLevel = .medium
        @State private var description: String = ""
        @State private var showingAlert = false
        @State private var alertMessage = ""
        
        let departments = ["Строительный", "Отделочный", "Электромонтажный", "Сантехнический", "Кровельный"]
        let units = ["шт", "кг", "м", "м²", "м³", "л", "упак", "тн"]
        
        private var isFormValid: Bool {
            let trimmedName = workerName.trimmingCharacters(in: .whitespaces)
            let trimmedMaterial = materialName.trimmingCharacters(in: .whitespaces)
            let trimmedQuantity = quantityString.trimmingCharacters(in: .whitespaces)
            
            return !trimmedName.isEmpty &&
                   !department.isEmpty &&
                   !trimmedMaterial.isEmpty &&
                   !trimmedQuantity.isEmpty &&
                   Double(trimmedQuantity) != nil &&
                   !unit.isEmpty
        }
        
        var body: some View {
            NavigationStack {
                Form {
                    Section("Заявитель") {
                        TextField("ФИО", text: $workerName)
                        Picker("Отдел", selection: $department) {
                            ForEach(departments, id: \.self) { dept in
                                Text(dept).tag(dept)
                            }
                        }
                    }
                    
                    Section("Материал") {
                        Picker("Материал", selection: $selectedMaterialType) {
                            ForEach(BuildingMaterial.allCases, id: \.self) { material in
                                Text(material.rawValue).tag(material)
                            }
                        }
                        TextField("Наименование (марка/тип)", text: $materialName)
                        
                        HStack {
                            TextField("Количество", text: $quantityString)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                                                
                            Picker("Ед.", selection: $unit) {
                                ForEach(units, id: \.self) { u in
                                    Text(u).tag(u)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        Picker("Срочность", selection: $selectedUrgency) {
                            ForEach(MaterialRequest.UrgencyLevel.allCases, id: \.self) { urgency in
                                Text(urgency.rawValue).tag(urgency)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section("Описание") {
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                    }
                    
                    Section {
                        Button("📤 Отправить") {
                            submitRequest()
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .tint(isFormValid ? .blue : .gray)
                        .disabled(!isFormValid)
                    }
                }
                .navigationTitle("Новая заявка")
                .alert("✅ Заявка", isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
            }
        }
        
        private func submitRequest() {
            guard !quantityString.isEmpty,
                  let quantity = Double(quantityString),
                  quantity > 0 else {
                alertMessage = "❌ Количество должно быть > 0"
                showingAlert = true
                return
            }
            
            let request = MaterialRequest(
                id: UUID(), workerName: workerName,
                department: department,
                materialType: selectedMaterialType,
                materialName: materialName,
                quantity: quantity,  // ✅ Обычная переменная quantity
                unit: unit,
                urgency: selectedUrgency,
                description: description,
                dateRequested: Date(),
                status: .pending
            )
            
            storageManager.saveRequest(request)
                alertMessage = "✅ Сохранено!"
                showingAlert = true
                clearForm()
            }
        private func clearForm() {
            workerName = ""
            department = ""
            materialName = ""
            quantityString = ""
            unit = "шт"
            description = ""
            selectedMaterialType = .cement
            selectedUrgency = .medium
        }
    }

