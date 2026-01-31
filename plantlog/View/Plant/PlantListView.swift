import SwiftUI
import SwiftData
import AVFoundation

struct PlantListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PlantListViewModel
    @StateObject private var router = NotificationRouter.shared

    init(modelContext: ModelContext) {
        let repository = PlantRepository(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: PlantListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            plantList
                .navigationTitle("My Plants")
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search by name or species"
                )
                .accessibilityLabel("Search plants")
                .accessibilityHint("Search plants by name or species")
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $viewModel.showingCreate) {
                    createPlantSheet
                }
                .sheet(item: $viewModel.editingPlant) { plant in
                    editPlantSheet(for: plant)
                }
                .navigationDestination(item: $viewModel.selectedPlant) { plant in
                    PlantDetailView(plant: plant, repository: PlantRepository(modelContext: modelContext))
                }
        }
        .onReceive(router.$lastPlantID.compactMap { $0 }) { id in
            viewModel.handleNotificationTap(plantID: id)
        }
    }
        
    private var plantList: some View {
        GlassEffectContainer(spacing: 12) {
            List {
                ForEach(viewModel.filteredPlants) { plant in
                    plantRow(for: plant)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
    
    private func plantRow(for plant: PlantModel) -> some View {
        NavigationLink {
            PlantDetailView(plant: plant, repository: PlantRepository(modelContext: modelContext))
        } label: {
            plantRowContent(for: plant)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deletePlant(plant)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .accessibilityLabel("Delete \(plant.name)")
        }
        .contextMenu {
            Button {
                viewModel.editingPlant = plant
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                viewModel.deletePlant(plant)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
    
    private func plantRowContent(for plant: PlantModel) -> some View {
        HStack(spacing: 16) {
            avatar(for: plant)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .accessibilityHidden(true)
            
            plantInfo(for: plant)
            
            Spacer(minLength: 8)
        }
        .padding(16)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tap to open plant details")
    }
    
    private func plantInfo(for plant: PlantModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(plant.name)
                .font(.headline)
                .accessibilityLabel("Plant name")
                .accessibilityValue(plant.name)
            Text(plant.species)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Species")
                .accessibilityValue(plant.species)
            Text("Next watering: \(plant.nextWateringDate().formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Next watering date")
                .accessibilityValue(plant.nextWateringDate().formatted(date: .long, time: .omitted))
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            addButton
        }
    }
    
    private var addButton: some View {
        Button {
            viewModel.showingCreate = true
        } label: {
            Image(systemName: "plus")
                .symbolRenderingMode(.monochrome)
        }
        .buttonStyle(.glassProminent)
        .accessibilityLabel("Add new plant")
        .accessibilityHint("Opens a form to add a new plant")
    }
    
    private var createPlantSheet: some View {
        PlantFormView(
            existingPlant: nil,
            onSave: { newPlant in
                viewModel.createPlant(newPlant)
            },
            onDelete: nil
        )
    }
    
    private func editPlantSheet(for plant: PlantModel) -> some View {
        PlantFormView(
            existingPlant: plant,
            onSave: { updated in
                viewModel.updatePlant(updated)
            },
            onDelete: {
                viewModel.deletePlant(plant)
            }
        )
    }

    @ViewBuilder
    private func avatar(for plant: PlantModel) -> some View {
        if let data = plant.imageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .accessibilityLabel("Photo of \(plant.name)")
        } else {
            DefaultLeafAvatar()
                .accessibilityLabel("Default leaf icon")
        }
    }
}

@available(iOS 26.0, *)
private struct DefaultLeafAvatar: View {
    @State private var trigger = false
    
    var body: some View {
        let bg = Color(hex: "#E0EF54")
        let leaf = Color(hex: "#607529")
        
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(bg)
            Image(systemName: "leaf.fill")
                .font(.title3)
                .foregroundStyle(leaf)
                .symbolEffect(.bounce, value: trigger)
        }
        .onAppear {
            trigger.toggle()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PlantModel.self, configurations: config)
    let context = container.mainContext
    
    return PlantListView(modelContext: context)
}
