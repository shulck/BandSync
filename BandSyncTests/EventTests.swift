import XCTest
@testable import BandSync

class EventTests: XCTestCase {
    func testEventLoading() {
        let viewModel = EventListViewModel()
        viewModel.loadEvents()
        
        XCTAssertFalse(viewModel.events.isEmpty, "Events should not be empty")
    }
}
