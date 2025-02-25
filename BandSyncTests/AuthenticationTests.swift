import XCTest
@testable import BandSync

class AuthenticationTests: XCTestCase {
    func testLogin() {
        let expectation = self.expectation(description: "Login")
        
        AuthenticationManager.shared.login(email: "test@example.com", password: "password") { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user.email, "test@example.com")
            case .failure(let error):
                XCTFail("Login failed: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
