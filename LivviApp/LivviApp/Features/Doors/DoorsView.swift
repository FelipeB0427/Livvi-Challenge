//
//  DoorsView.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import SwiftUI

struct DoorsView: View {
    @StateObject private var viewModel = DoorsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.doors.isEmpty {
                    ProgressView("Loading Doors...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if viewModel.doors.isEmpty && !viewModel.searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .padding(.bottom, 10)
                            .foregroundColor(.gray)
                        
                        Text("No doors found for \"\(viewModel.searchText)\"")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.doors) { door in
                            DoorRowView(door: door)
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreDoorsIfNeeded(currentDoor: door)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.refreshDoors()
                    }
                }
            }
            .navigationTitle("Doors")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search Doors"
            )
            .task {
                if viewModel.doors.isEmpty {
                    await viewModel.loadInitialDoors()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                Button("OK") { viewModel.errorMessage = nil }
            } message: { errorMessage in
                Text(errorMessage)
            }
        }
    }
    
    struct DoorRowView: View {
        let door: Door
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(door.name)
                    .font(.headline)
                
                Text(door.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: batteryIcon)
                        .foregroundColor(batteryColor)
                    
                    Text("Battery: \(door.battery)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 8)
        }
        
        private var batteryIcon: String {
            switch door.battery {
            case 0: return "battery.0"
            case 1...20: return "battery.25"
            case 21...50: return "battery.50"
            case 51...99: return "battery.75"
            default: return "battery.100"
            }
        }
        
        private var batteryColor: Color {
            switch door.battery {
            case 0...20: return .red
            case 21...74: return .orange
            default: return .green
            }
        }
    }
}
    
    
