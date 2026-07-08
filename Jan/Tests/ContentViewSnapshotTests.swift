import SnapshotTesting
import SwiftUI
import XCTest
@testable import Jan

final class ContentViewSnapshotTests: XCTestCase {
    func test_contentView() {
        let view = UIHostingController(rootView: ContentView())
        assertSnapshot(of: view, as: .image(on: .iPhone13ProMax))
    }
}
