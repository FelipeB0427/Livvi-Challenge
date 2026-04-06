//
//  EventsViewModel.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation
import Combine

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [ParsedBLEEvent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let doorId: Int
    private let networkService: NetworkServiceProtocol
    private let parser: BLEEventParser
    
    // MARK: - Pagination State
    private var currentPage = 0
    private let pageSize = 20
    private var hasMorePages = true
    private var isFetching = false
    
    init(
        doorId: Int,
        networkService: NetworkServiceProtocol = NetworkService(authStore: KeychainAuthStore()),
        parser: BLEEventParser = BLEEventParser()
    ) {
        self.doorId = doorId
        self.networkService = networkService
        self.parser = parser
    }
    
    func loadInitialEvents() async {
        await fetchEvents(reset: true)
    }
    
    func loadMoreIfNeeded(currentEvent: ParsedBLEEvent) async {
        guard let lastEvent = events.last, lastEvent.id == currentEvent.id else { return }
        guard hasMorePages, !isFetching else { return }
        
        currentPage += 1
        await fetchEvents()
    }
    
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
            
            let response: PaginatedResponse<String> = try await networkService.request(endpoint)
            let rawBase64Strings = response.content ?? []
            
            var parsedEvents: [ParsedBLEEvent] = []
            
            for base64 in rawBase64Strings {
                do {
                    let event = try parser.parse(base64String: base64)
                    parsedEvents.append(event)
                } catch {
                    print("⚠️ Failed to parse BLE event: \(base64) - Error: \(error)")
                }
            }
            
            self.events.append(contentsOf: parsedEvents)
            
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
