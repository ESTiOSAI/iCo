//
//  MyPageView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MyPageView: View {
    var body: some View {
		CoreDataCRUDTestView()
    }
}

#Preview {
    MyPageView()
}

struct CoreDataCRUDTestView: View {
    @StateObject private var vm = TestViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Core Data CRUD Test")
                .font(.headline)

            HStack {
                Button("Create ▶️") {
                    vm.createTest()
                }
                Button("Read ▶️") {
                    vm.readTest()
                }
            }

            HStack {
                Button("Update ▶️") {
                    vm.updateTest()
                }
                Button("Delete ▶️") {
                    vm.deleteTest()
                }
            }

            Divider()

            List(vm.bookmarks, id: \.objectID) { bookmark in
                HStack {
                    Text(bookmark.coinID ?? "-")
                    Spacer()
                    Text("\(bookmark.timestamp ?? Date(), formatter: vm.dateFormatter)")
                        .font(.caption)
                }
            }
        }
        .padding()
        .onAppear { vm.readTest() }
    }
}

final class TestViewModel: ObservableObject {
    @Published var bookmarks: [BookmarkEntity] = []
    private let manager: BookmarkManaging = BookmarkManager()

    let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()

    func createTest() {
        Task {
            do {
                try manager.add(coinID: "TEST-\(Int.random(in: 1...999))")
                print("✅ Created a test bookmark")
                await MainActor.run { readTest() }
            } catch {
                print("❌ Create failed:", error)
            }
        }
    }

    func readTest() {
        Task {
            do {
                let all = try manager.fetchRecent(limit: 50)
                await MainActor.run { bookmarks = all }
                print("📖 Read \(all.count) bookmarks")
            } catch {
                print("❌ Read failed:", error)
            }
        }
    }

    func updateTest() {
        Task {
            do {
                guard let first = bookmarks.first else {
                    print("⚠️ No bookmarks to update")
                    return
                }
                // update timestamp to now
                first.timestamp = Date()
                try manager.add(coinID: first.coinID ?? "")
                print("✏️ Updated first bookmark timestamp")
                await MainActor.run { readTest() }
            } catch {
                print("❌ Update failed:", error)
            }
        }
    }

    func deleteTest() {
        Task {
            do {
                if let first = bookmarks.first {
                    try manager.remove(coinID: first.coinID ?? "")
                    print("🗑 Deleted first bookmark")
                    await MainActor.run { readTest() }
                } else {
                    print("⚠️ No bookmarks to delete")
                }
            } catch {
                print("❌ Delete failed:", error)
            }
        }
    }
}

struct CoreDataCRUDTestView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataCRUDTestView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
