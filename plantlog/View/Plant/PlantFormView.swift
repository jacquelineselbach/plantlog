import SwiftUI
import PhotosUI
import SwiftData
import AVFoundation

struct PlantFormView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PlantFormViewModel
    @Namespace private var photoNamespace

    let onSave: (PlantModel) -> Void
    let onDelete: (() -> Void)?

    init(
        existingPlant: PlantModel? = nil,
        onSave: @escaping (PlantModel) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: PlantFormViewModel(existingPlant: existingPlant))
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationStack {
            GlassEffectContainer(spacing: 16) {
                ScrollView {
                    VStack(spacing: 20) {
                        plantInfoSection
                        photoSection
                        wateringSection
                        
                        if viewModel.isEditing, let onDelete {
                            deleteSection(onDelete: onDelete)
                        }
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .symbolRenderingMode(.monochrome)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancel editing plant")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        savePlant()
                    } label: {
                        Image(systemName: "checkmark")
                            .symbolRenderingMode(.monochrome)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.isValid)
                    .accessibilityLabel("Save plant")
                    .accessibilityHint(viewModel.isValid ? "Saves the plant" : "Plant name is required")
                }
            }
            .task(id: viewModel.selectedPhoto) {
                await viewModel.loadSelectedPhoto()
            }
            .onAppear {
                viewModel.checkCameraPermission()
            }
            .alert("Camera Permission", isPresented: $viewModel.showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.cameraModel.errorMessage)
            }
            .sheet(isPresented: $viewModel.showCameraView) {
                CameraCaptureView(cameraModel: viewModel.cameraModel) { data in
                    viewModel.handleCameraCapture(data)
                }
            }
        }
    }
    
    
    private var plantInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                Text("Plant Information")
                    .font(.subheadline.bold())
                Spacer()
            }
            
            VStack(spacing: 12) {
                CustomTextField(
                    icon: "text.cursor",
                    placeholder: "Name",
                    text: $viewModel.name
                )
                .accessibilityLabel("Plant name")
                
                CustomTextField(
                    icon: "leaf",
                    placeholder: "Species",
                    text: $viewModel.species
                )
                .accessibilityLabel("Plant species")
            }
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .glassEffectID("plantInfo", in: photoNamespace)
    }
    
    private var photoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "photo.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                Text("Photo")
                    .font(.subheadline.bold())
                Spacer()
            }
            
            HStack(spacing: 16) {
                photoPreview
                    .glassEffectID("photoPreview", in: photoNamespace)
                
                VStack(spacing: 10) {
                    PhotosPicker(
                        selection: $viewModel.selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Choose plant photo")
                    
                    Button {
                        viewModel.openCamera()
                    } label: {
                        HStack {
                            Label("Take Photo", systemImage: "camera")
                            if !viewModel.cameraModel.hasPermission {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Take photo with camera")
                    .accessibilityHint(viewModel.cameraModel.hasPermission ? "Opens camera" : "Camera permission required")
                }
            }
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .glassEffectID("photo", in: photoNamespace)
    }
    
    private var wateringSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                Text("Watering Schedule")
                    .font(.subheadline.bold())
                Spacer()
            }
            
            VStack(spacing: 16) {
                Picker("Schedule Type", selection: $viewModel.scheduleType) {
                    Label("Interval", systemImage: "calendar.badge.clock")
                        .tag(WateringScheduleType.interval)
                    Label("Weekday", systemImage: "calendar.day.timeline.left")
                        .tag(WateringScheduleType.weekday)
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Watering schedule type")
                
                Divider()
                    .padding(.vertical, 4)
                
                if viewModel.scheduleType == .interval {
                    intervalScheduleView
                } else {
                    weekdayScheduleView
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.blue)
                        .symbolRenderingMode(.hierarchical)
                    Text("Watering Time")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    DatePicker(
                        "",
                        selection: $viewModel.wateringTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .accessibilityLabel("Watering time")
                }
            }
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .glassEffectID("watering", in: photoNamespace)
    }
    
    private var intervalScheduleView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "repeat")
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Repeat Every")
                        .font(.subheadline.weight(.medium))
                    Text("\(viewModel.wateringIntervalDays) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Stepper("", value: $viewModel.wateringIntervalDays, in: 1...60)
                    .labelsHidden()
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue("\(viewModel.wateringIntervalDays) days")
            
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                Text("Start Date")
                    .font(.subheadline.weight(.medium))
                Spacer()
                DatePicker(
                    "",
                    selection: $viewModel.startDate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .accessibilityLabel("Start date")
            }
        }
    }
    
    private var weekdayScheduleView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                Text("Select Weekday")
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            
            Picker("Weekday", selection: Binding(
                get: { viewModel.weekday ?? 2 },
                set: { viewModel.weekday = $0 }
            )) {
                ForEach(1...7, id: \.self) { index in
                    Text(viewModel.weekdaySymbols[index - 1])
                        .tag(index)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .accessibilityLabel("Select weekday")
        }
    }
    
    private func deleteSection(onDelete: @escaping () -> Void) -> some View {
        Button(role: .destructive) {
            onDelete()
            dismiss()
        } label: {
            HStack {
                Image(systemName: "trash.circle.fill")
                    .font(.title3)
                Text("Delete Plant")
                    .font(.headline)
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(.red.opacity(0.2)), in: .rect(cornerRadius: 20))
        .accessibilityLabel("Delete plant")
        .accessibilityHint("Deletes the current plant permanently")
    }

    @ViewBuilder
    private var photoPreview: some View {
        if let imageData = viewModel.imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .glassEffect(.regular, in: .rect(cornerRadius: 16))
                .accessibilityLabel("Photo of plant")
                .accessibilityAddTraits(.isImage)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#E0EF54").gradient)
                    .frame(width: 100, height: 100)
                Image(systemName: "leaf.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: "#607529"))
                    .symbolEffect(.bounce)
                    .accessibilityHidden(true)
            }
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
            .accessibilityLabel("Default leaf icon")
        }
    }

    private func savePlant() {
        let plant = viewModel.buildPlant()
        onSave(plant)
        dismiss()
    }
}

@available(iOS 26.0, *)
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground).opacity(0.5))
        }
    }
}

