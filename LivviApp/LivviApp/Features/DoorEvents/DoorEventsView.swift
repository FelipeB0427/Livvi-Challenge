//
//  DoorEventsView.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import SwiftUI

struct DoorEventsView: View {
    @StateObject private var viewModel: DoorEventsViewModel
    
    init(doorId: Int) {
        _viewModel = StateObject(wrappedValue: DoorEventsViewModel(doorId: doorId))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.events.isEmpty {
                ProgressView("Loading Events...")
            } else if viewModel.events.isEmpty {
                VStack {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("There is no events registered")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            } else {
                List {
                    ForEach(viewModel.events) { event in
                        EventRowView(event: event)
                            .onAppear {
                                Task {
                                    await viewModel.loadMoreIfNeeded(currentEvent: event)
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle("Door History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.events.isEmpty {
                await viewModel.loadInitialEvents()
            }
        }
        .alert("Ops!", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
            Button("OK") { viewModel.errorMessage = nil }
        } message: { errorMessage in
            Text(errorMessage)
        }
    }
}

struct EventRowView: View {
    let event: ParsedBLEEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: iconForEvent(event.eventType))
                    .foregroundColor(.blue)
                
                Text(event.eventType)
                    .font(.headline)
                
                Spacer()
                
                Text(formatDate(event.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(event.payloadDetails)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 28)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func iconForEvent(_ type: String) -> String {
        switch type {
        case "Unlock": return "lock.open.fill"
        case "Unlock Denied": return "lock.slash.fill"
        case "Door Open": return "door.left.hand.open"
        case "Door Close": return "door.left.hand.closed"
        case "Battery Low": return "battery.25"
        default: return "bolt.circle.fill"
        }
    }
}
