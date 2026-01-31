import SwiftUI
import SwiftData
import UIKit

struct PlantDetailView: View {
    
    @Environment(\.calendar) private var calendar
    @StateObject private var viewModel: PlantDetailViewModel
    @Namespace private var imageNS

    init(plant: PlantModel, repository: PlantRepository) {
        _viewModel = StateObject(wrappedValue: PlantDetailViewModel(
            plant: plant,
            repository: repository
        ))
    }

    private var weekdaySymbols: [String] { calendar.weekdaySymbols }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                content
                    .disabled(viewModel.isImageExpanded)

                if viewModel.isImageExpanded,
                   let data = viewModel.plant.imageData,
                   let uiImage = UIImage(data: data) {
                    expandedOverlay(uiImage: uiImage, proxy: proxy)
                        .zIndex(10)
                        .transition(.opacity)
                        .accessibilityAddTraits(.isModal)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Plant details for \(viewModel.plant.name)")
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {

                HStack(alignment: .center, spacing: 16) {
                    plantImageView
                    plantInfoView
                    Spacer()
                }

                careSection

                Button {
                    viewModel.showWaterSheet = true
                } label: {
                    Label("Watered now", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Mark as watered now")

                if viewModel.hasWateringHistory {
                    recentWateringSection
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.plant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .symbolRenderingMode(.monochrome)
                }
                .buttonStyle(.glassProminent)
                .accessibilityLabel("Edit plant")
                .accessibilityHint("Opens form to edit plant details")
            }
        }
        .sheet(isPresented: $viewModel.showWaterSheet) {
            WaterAmountView(
                amountMl: $viewModel.amountMl,
                onCancel: {
                    viewModel.cancelWatering()
                },
                onSave: {
                    viewModel.addWateringEvent()
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showCalendarSheet) {
            NavigationStack {
                WateringCalendarView(
                    plant: viewModel.plant,
                    selectedDay: $viewModel.selectedDay
                )
                .navigationTitle("Watering calendar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { viewModel.showCalendarSheet = false }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            PlantFormView(
                existingPlant: viewModel.plant,
                onSave: { updatedPlant in
                    viewModel.updatePlant(updatedPlant)
                    viewModel.showEditSheet = false
                },
                onDelete: nil
            )
        }
    }

    private var plantImageView: some View {
        let bg = Color(hex: "#E0EF54")
        let leaf = Color(hex: "#607529")

        return Group {
            if let data = viewModel.plant.imageData,
               let uiImage = UIImage(data: data) {
                heroCircleImage(uiImage: uiImage, expanded: false)
                    .opacity(viewModel.isImageExpanded ? 0 : 1)
                    .onTapGesture {
                        viewModel.toggleImageExpansion()
                    }
                    .accessibilityLabel("Photo of \(viewModel.plant.name), double tap to enlarge")
                    .accessibilityAddTraits(.isButton)
            } else {
                DefaultLeafCircle(bg: bg, leaf: leaf)
                    .accessibilityLabel("Default leaf icon")
            }
        }
    }

    private var plantInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.plant.name)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("Plant name")
                .accessibilityValue(viewModel.plant.name)
            Text(viewModel.plant.species)
                .font(.headline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Species")
                .accessibilityValue(viewModel.plant.species)
        }
    }

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Care")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Divider()

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next watering")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.nextWateringDateString)
                        .font(.body)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Next watering date")
                .accessibilityValue(viewModel.nextWateringDateString)

                Spacer()

                Button {
                    viewModel.showCalendarSheet = true
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                        .frame(height: 40)
                }
                .accessibilityLabel("Open watering calendar")
                .accessibilityHint("Shows watering history calendar")
                .buttonStyle(.plain)
            }

            Divider()

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last watered")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.lastWateredString)
                        .font(.body)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Last watered date")
                .accessibilityValue(viewModel.lastWateredString)

                Spacer()

                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                    .frame(height: 40)
                    .accessibilityHidden(true)
            }

            Divider()

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Schedule")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.scheduleDescription)
                        .font(.body)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Watering schedule")
                .accessibilityValue(viewModel.scheduleDescription)

                Spacer()

                Image(systemName: "clock")
                    .foregroundStyle(.blue)
                    .frame(height: 40)
                    .accessibilityHidden(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background.secondary)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var recentWateringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent watering")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button("Calendar") { viewModel.showCalendarSheet = true }
                    .font(.subheadline)
                    .accessibilityLabel("Open watering calendar")
            }

            Divider()

            ForEach(
                viewModel.recentWateringEvents,
                id: \.persistentModelID
            ) { event in
                HStack {
                    Text(event.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(event.amountMl.map { "\($0) ml" } ?? "—")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Watered on \(event.date.formatted(date: .long, time: .shortened))")
                .accessibilityValue(event.amountMl.map { "\($0) milliliters" } ?? "amount not specified")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background.secondary)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func heroCircleImage(uiImage: UIImage, expanded: Bool) -> some View {
        let size: CGFloat = expanded ? 280 : 72

        return Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
            .clipShape(Circle())
            .matchedGeometryEffect(id: "plantImage", in: imageNS)
            .shadow(color: .black.opacity(expanded ? 0.18 : 0.0),
                    radius: expanded ? 18 : 0,
                    x: 0,
                    y: expanded ? 10 : 0)
    }

    private func expandedOverlay(uiImage: UIImage, proxy: GeometryProxy) -> some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.toggleImageExpansion()
                }
                .accessibilityHidden(true)

            heroCircleImage(uiImage: uiImage, expanded: true)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                .onTapGesture {
                    viewModel.toggleImageExpansion()
                }
                .accessibilityLabel("Expanded photo of \(viewModel.plant.name), double tap to close")
                .accessibilityAddTraits(.isButton)

            Button("Close") {
                viewModel.toggleImageExpansion()
            }
            .padding()
            .accessibilityLabel("Close expanded photo")
        }
    }
}

private struct DefaultLeafCircle: View {
    let bg: Color
    let leaf: Color
    @State private var trigger = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(bg)
                .frame(width: 72, height: 72)
            
            Image(systemName: "leaf.fill")
                .font(.system(size: 32))
                .foregroundStyle(leaf)
                .symbolEffect(.bounce, value: trigger)
        }
        .onAppear {
            trigger.toggle()
        }
    }
}

