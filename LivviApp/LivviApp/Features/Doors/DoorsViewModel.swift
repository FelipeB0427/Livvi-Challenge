//
//  DoorsViewModel.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation
import Combine

@MainActor
/// DoorsViewModel loads and paginates `Door` items from the backend and exposes them to the UI.
///
/// Supports searching by name with debounce, pagination and error handling.
class DoorsViewModel: ObservableObject {
    @Published var doors: [Door] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var searchText: String = "" {
        didSet {
            performSearchWithDebounce()
        }
    }
    
    // MARK: - Pagination State
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var hasMorePages: Bool = true
    private var isFetching: Bool = false
    
    private var searchTask: Task<Void, Never>?
    private let networkService: NetworkServiceProtocol
    
    /// Initialize the view model with an optional `NetworkServiceProtocol` for testing.
    init(networkService: NetworkServiceProtocol? = nil) {
        self.networkService = networkService ?? NetworkService(authStore: KeychainAuthStore())
    }
    
    /// Load the first page of doors.
    func loadInitialDoors() async {
        await fetchDoors(reset: true)
    }
    
    /// Request to load more doors when the given `currentDoor` is visible.
    func loadMoreDoorsIfNeeded(currentDoor: Door) async {
        guard let lastDoor = doors.last, lastDoor.id == currentDoor.id else { return }
        guard hasMorePages, !isFetching else { return }
        
        currentPage += 1
        await fetchDoors()
    }
    
    /// Refresh the doors list resetting pagination.
    func refreshDoors() async {
        await fetchDoors(reset: true)
    }
    
    private func performSearchWithDebounce() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms debounce
            
            guard !Task.isCancelled else { return }
            
            await fetchDoors(reset: true)
        }
    }
    
    private func fetchDoors(reset: Bool = false) async {
        if reset {
            currentPage = 0
            hasMorePages = true
            doors = []
        }
        
        guard hasMorePages, !isFetching else { return }
        
        isFetching = true
        if doors.isEmpty { isLoading = true }
        errorMessage = nil
        
        let endpoint: DoorsEndpoint
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            endpoint = .list(page: currentPage, pageSize: pageSize)
        } else {
            endpoint = .find(name: searchText, page: currentPage, pageSize: pageSize)
        }
        
        do {
            let response: PaginatedResponse<Door> = try await networkService.request(endpoint)
            
            self.doors.append(contentsOf: response.content)
            
            self.hasMorePages = response.page < (response.totalPages - 1)
        } catch let NetworkError.httpError(_, apiError) {
            self.errorMessage = apiError?.description ?? "An unknown error occurred."
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
        
        isFetching = false
        isLoading = false
    }
}
