//
//  EventsViewModel.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation
import Combine

@MainActor
/// DoorEventsViewModel fetches raw events from the backend and maps them into `ParsedBLEEvent` objects
/// for display. It handles pagination and error mapping.
class DoorEventsViewModel: ObservableObject {
    @Published var events: [ParsedBLEEvent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    let doorId: Int
    private let networkService: NetworkServiceProtocol
    private let parser: BLEEventParser
    
    // MARK: - Pagination State
    private var currentPage = 0
    private let pageSize = 20
    private var hasMorePages = true
    private var isFetching = false
    
    /// Initialize with a door id; optional dependencies can be injected for testing.
    init(
        doorId: Int,
        networkService: NetworkServiceProtocol? = nil,
        parser: BLEEventParser? = nil
    ) {
        self.doorId = doorId
        self.networkService = networkService ?? NetworkService(authStore: KeychainAuthStore())
        self.parser = parser ?? BLEEventParser()
    }
    
    /// Load events starting from page 0.
    func loadInitialEvents() async {
        await fetchEvents(reset: true)
    }
    
    /// Load more events when the given `currentEvent` is visible.
    func loadMoreIfNeeded(currentEvent: ParsedBLEEvent) async {
        guard let lastEvent = events.last, lastEvent.id == currentEvent.id else { return }
        guard hasMorePages, !isFetching else { return }
        
        currentPage += 1
        await fetchEvents()
    }
    
    /// Refresh events resetting pagination.
    func refresh() async {
        await fetchEvents(reset: true)
    }
    
    private func fetchEvents(reset: Bool = false) async {
        if reset {
            currentPage = 0
            hasMorePages = true
            events = []
        }
        
        guard hasMorePages, !isFetching else { return }
        
        isFetching = true
        if events.isEmpty { isLoading = true }
        errorMessage = nil
        
        let endpoint = EventsEndpoint.rawEvents(doorId: doorId, page: currentPage, size: pageSize)
        
        do {
            let response: PaginatedResponse<APIEvent> = try await networkService.request(endpoint)
            let apiEvents = response.content
            
            let formatter = ISO8601DateFormatter()
            
            let mappedEvents: [ParsedBLEEvent] = apiEvents.map { apiEvent in
                let date = formatter.date(from: apiEvent.eventTimestamp) ?? Date()
                
                let details = apiEvent.additionalData
                    .map { "\($0.parameterName): \($0.parsedValue)" }
                    .joined(separator: " | ")
                
                let finalDetails = details.isEmpty ? "No additional data" : details
                
                let formattedType = apiEvent.logType
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
                
                return ParsedBLEEvent(timestamp: date, eventType: formattedType, payloadDetails: finalDetails)
            }
            
            self.events.append(contentsOf: mappedEvents)
            self.hasMorePages = response.page < (response.totalPages - 1)
            
        } catch let NetworkError.httpError(_, apiError) {
            self.errorMessage = apiError?.description ?? "Failed to load events."
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
        
        isFetching = false
        isLoading = false
    }
    
}
