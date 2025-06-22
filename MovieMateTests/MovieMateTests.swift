//
//  MovieMateTests.swift
//  MovieMateTests
//
//  Created by Aleksandr on 13.09.2024.
//

import XCTest
import Combine
@testable import MovieMate

class MovieServiceBackgroundTests: XCTestCase {

    var movieService: MovieServiceBackground!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        movieService = MovieServiceBackground()
    }

    override func tearDown() {
        cancellables.removeAll()
        movieService = nil
        super.tearDown()
    }

    func testFetchPopularMovies() {
        let expectation = XCTestExpectation(description: "Fetch popular movies")

        movieService.fetchPopularMovies(page: 1)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { moviesResponse in
                XCTAssertNotNil(moviesResponse, "Movies response should not be nil")
                XCTAssertGreaterThan(moviesResponse.results.count, 0, "Movies list should contain at least one movie")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }
}
