//
//  vitesseTests.swift
//  vitesseTests
//
//  Created by pascal jesenberger on 20/02/2025.
//

import XCTest
@testable import vitesse

// MARK: - LoginViewModelTests
final class LoginViewModelTests: XCTestCase {
    
    var viewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Validation Tests
    
    func testValidEmail() {
        viewModel.email = "test@example.com"
        viewModel.validateEmail()
        XCTAssertTrue(viewModel.isEmailValid, "Valid email should pass validation")
    }
    
    func testInvalidEmail() {
        viewModel.email = "invalid-email"
        viewModel.validateEmail()
        XCTAssertFalse(viewModel.isEmailValid, "Invalid email should fail validation")
    }
    
    func testEmptyFields() {
        viewModel.email = ""
        viewModel.password = ""
        viewModel.validateEmptyFields()
        XCTAssertTrue(viewModel.hasEmptyFields, "Empty fields should be detected")
    }
    
    func testFormValidation() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        viewModel.validateEmail()
        XCTAssertTrue(viewModel.isFormValid, "Form should be valid with proper values")
        
        viewModel.email = "invalid"
        viewModel.validateEmail()
        XCTAssertFalse(viewModel.isFormValid, "Form should be invalid with improper email")
    }
    
    // MARK: - Login Tests
    
    @MainActor func testLoginWithInvalidFormShouldNotProceed() {
        // Using a sync method to check behavior without network call
        viewModel.email = "invalid"
        viewModel.password = "pass"
        
        let expectation = XCTestExpectation(description: "Login should not be attempted")
        expectation.isInverted = true
        
        viewModel.login()
        
        XCTAssertFalse(viewModel.isLoading, "Loading state should not be triggered with invalid form")
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    @MainActor func testLoginWithValidFormShouldProceed() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        let expectation = XCTestExpectation(description: "Login should be attempted")
        
        viewModel.login()
        
        XCTAssertTrue(viewModel.isLoading, "Loading state should be triggered with valid form")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testLoginWithNetworkError() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        let expectation = XCTestExpectation(description: "Login should handle network error")
        
        viewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.error, "Error should be set when network request fails")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    @MainActor func testLoginSuccess() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        let expectation = XCTestExpectation(description: "Login should succeed")
        
        viewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.viewModel.isLoggedIn, "User should be logged in after successful login")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - RegisterViewModelTests
final class RegisterViewModelTests: XCTestCase {
    
    var viewModel: RegisterViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = RegisterViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Validation Tests
    
    func testPasswordsMatch() {
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.validatePasswords()
        XCTAssertTrue(viewModel.passwordsMatch, "Identical passwords should match")
        
        viewModel.confirmPassword = "differentPassword"
        viewModel.validatePasswords()
        XCTAssertFalse(viewModel.passwordsMatch, "Different passwords should not match")
    }
    
    func testEmptyFields() {
        viewModel.firstName = ""
        viewModel.lastName = "Doe"
        viewModel.email = "john@example.com"
        viewModel.password = "password"
        viewModel.confirmPassword = "password"
        
        viewModel.validateEmptyFields()
        XCTAssertTrue(viewModel.hasEmptyFields, "Should detect empty firstName field")
        
        viewModel.firstName = "John"
        viewModel.lastName = ""
        viewModel.validateEmptyFields()
        XCTAssertTrue(viewModel.hasEmptyFields, "Should detect empty lastName field")
    }
    
    func testFormValidation() {
        // Set valid data
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        viewModel.validateEmail()
        viewModel.validatePasswords()
        
        XCTAssertTrue(viewModel.isFormValid, "Form should be valid with proper values")
        
        // Test with invalid email
        viewModel.email = "invalid"
        viewModel.validateEmail()
        XCTAssertFalse(viewModel.isFormValid, "Form should be invalid with improper email")
        
        // Test with mismatched passwords
        viewModel.email = "john@example.com"
        viewModel.confirmPassword = "different"
        viewModel.validatePasswords()
        XCTAssertFalse(viewModel.isFormValid, "Form should be invalid with mismatched passwords")
    }
    
    @MainActor func testRegisterWithValidFormShouldProceed() {
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        let expectation = XCTestExpectation(description: "Register should be attempted")
        
        viewModel.register()
        
        XCTAssertTrue(viewModel.isLoading, "Loading state should be triggered with valid form")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor func testRegisterWithNetworkError() {
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "john@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        let expectation = XCTestExpectation(description: "Register should handle network error")
        
        viewModel.register()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.error, "Error should be set when network request fails")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - CandidateViewModelTests
final class CandidateViewModelTests: XCTestCase {
    
    var viewModel: CandidateViewModel!
    let mockCandidate1 = Candidate(id: "1", firstName: "John", lastName: "Doe", email: "john@example.com", phone: nil, note: nil, linkedinURL: nil, isFavorite: false)
    let mockCandidate2 = Candidate(id: "2", firstName: "Jane", lastName: "Smith", email: "jane@example.com", phone: "12345678", note: "Note", linkedinURL: "linkedin.com/in/jane", isFavorite: true)
    
    override func setUp() {
        super.setUp()
        viewModel = CandidateViewModel()
        // Load candidates for filtering tests
        viewModel.candidates = [mockCandidate1, mockCandidate2]
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Utility Method Tests
    
    func testValidEmail() {
        XCTAssertTrue(viewModel.isValidEmail("test@example.com"), "Should validate correct email")
        XCTAssertFalse(viewModel.isValidEmail("invalid"), "Should reject invalid email")
    }
    
    func testValidPhoneNumber() {
        XCTAssertTrue(viewModel.isValidPhoneNumber("12345678"), "Should validate correct phone number")
        XCTAssertFalse(viewModel.isValidPhoneNumber("abc"), "Should reject invalid phone number")
    }
    
    // MARK: - Candidate Selection Tests
    
    func testToggleSelection() {
        XCTAssertFalse(viewModel.isSelected("1"), "Candidate should not be selected initially")
        
        viewModel.isEditing = true
        viewModel.toggleSelection("1")
        XCTAssertTrue(viewModel.isSelected("1"), "Candidate should be selected after toggle")
        
        viewModel.toggleSelection("1")
        XCTAssertFalse(viewModel.isSelected("1"), "Candidate should be deselected after second toggle")
    }
    
    func testClearSelection() {
        viewModel.isEditing = true
        viewModel.toggleSelection("1")
        viewModel.toggleSelection("2")
        
        XCTAssertEqual(viewModel.selectedCandidateIds.count, 2, "Should have 2 selected candidates")
        
        viewModel.clearSelection()
        XCTAssertEqual(viewModel.selectedCandidateIds.count, 0, "Should have no selected candidates after clear")
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        // Filter by first name
        viewModel.searchText = "John"
        XCTAssertEqual(viewModel.filteredCandidates.count, 1, "Should filter to only John")
        XCTAssertEqual(viewModel.filteredCandidates.first?.id, "1", "Should find candidate with ID 1")
        
        // Filter by last name
        viewModel.searchText = "Smith"
        XCTAssertEqual(viewModel.filteredCandidates.count, 1, "Should filter to only Smith")
        XCTAssertEqual(viewModel.filteredCandidates.first?.id, "2", "Should find candidate with ID 2")
        
        // Filter by email
        viewModel.searchText = "jane@"
        XCTAssertEqual(viewModel.filteredCandidates.count, 1, "Should filter to only Jane by email")
        XCTAssertEqual(viewModel.filteredCandidates.first?.id, "2", "Should find candidate with ID 2")
        
        // Empty search should return all
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filteredCandidates.count, 2, "Should return all candidates with empty search")
    }
    
    func testFavoriteFiltering() {
        // First test without favorite filtering
        viewModel.isFavoritesFiltering = false
        XCTAssertEqual(viewModel.filteredCandidates.count, 2, "Should return all candidates without favorite filtering")
        
        // Then enable favorite filtering
        viewModel.isFavoritesFiltering = true
        XCTAssertEqual(viewModel.filteredCandidates.count, 1, "Should return only favorite candidates")
        XCTAssertEqual(viewModel.filteredCandidates.first?.id, "2", "Should find candidate with ID 2")
    }
    
    func testCombinedFiltering() {
        // Combined filtering: favorites + search
        viewModel.isFavoritesFiltering = true
        viewModel.searchText = "Jane"
        
        XCTAssertEqual(viewModel.filteredCandidates.count, 1, "Should return only Jane with combined filtering")
        XCTAssertEqual(viewModel.filteredCandidates.first?.id, "2", "Should find candidate with ID 2")
        
        // No results scenario
        viewModel.searchText = "John"
        XCTAssertEqual(viewModel.filteredCandidates.count, 0, "Should return no results when filtering for John in favorites")
    }
    
    @MainActor func testLoadCandidates() {
        let expectation = XCTestExpectation(description: "Candidates should be loaded")
        
        viewModel.loadCandidates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.candidates.isEmpty, "Candidates should be loaded")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    @MainActor func testLoadCandidatesWithError() {
        let expectation = XCTestExpectation(description: "Candidates loading should handle error")
        
        viewModel.loadCandidates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.error, "Error should be set when candidates loading fails")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - APIServiceMock
class APIServiceMock {
    var loginSuccessful = true
    var registerSuccessful = true
    var loadCandidatesSuccessful = true
    
    func authenticate(email: String, password: String) async throws -> AuthResponse {
        if loginSuccessful {
            return AuthResponse(token: "mock-token", isAdmin: true)
        } else {
            throw APIError.loginFailed
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String) async throws {
        if !registerSuccessful {
            throw APIError.registrationFailed
        }
    }
    
    func getAllCandidates() async throws -> [Candidate] {
        if loadCandidatesSuccessful {
            return [
                Candidate(id: "1", firstName: "John", lastName: "Doe", email: "john@example.com", phone: nil, note: nil, linkedinURL: nil, isFavorite: false),
                Candidate(id: "2", firstName: "Jane", lastName: "Smith", email: "jane@example.com", phone: "12345678", note: "Note", linkedinURL: "linkedin.com/in/jane", isFavorite: true)
            ]
        } else {
            throw APIError.invalidResponse
        }
    }
}
