//
//  MoreSfSymbolsView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 2/23/24.
//

import SwiftUI

struct MoreSfSymbolsView: View {
    @Environment(\.dismiss) var dismiss

    let emojisByCategory: [[String]] = [
        ["lightbulb", "leaf", "gamecontroller", "heart.text.square", "graduationcap", "bell", "gift.fill", "heart", "laptopcomputer", "airplane"],
        ["soccerball", "baseball.fill", "basketball.fill", "football", "skateboard", "trophy", "dumbbell", "tennis.racket", "figure.surfing", "figure.skiing.downhill", "sportscourt"],
        ["car", "airplane.departure", "ferry", "sailboat", "fuelpump", "gym.bag", "bus", "bicycle", "map"],
        ["sun.max", "snowflake", "moon", "cloud", "cloud.rain", "wind", "rainbow", "bolt", "sparkles"],
        ["mountain.2", "tree", "laurel.leading", "atom", "carrot", "hare", "tortoise", "dog", "cat", "bird", "fish", "pawprint"],
        ["house", "heater.vertical", "air.conditioner.vertical", "shower", "frying.pan", "party.popper", "balloon", "popcorn", "sofa", "trash"],
        ["stethoscope", "lungs", "microbe", "waveform.path.ecg.rectangle", "brain", "eye", "pills", "bandage", "microbe"],
        ["books.vertical", "book", "book.closed", "bookmark", "backpack", "note.text", "list.bullet.clipboard", "archivebox", "doc", "folder", "pencil"],
        ["display", "camera", "paintpalette", "theatermask.and.paintbrush", "playpause.fill", "music.note", "guitars", "pianokeys.inverse"],
        ["key", "figure.2.and.child.holdinghands", "figure.2.arms.open", "eyes.inverse", "mic", "bubble.left", "envelope"],
    ]

    let emojiSectionTitles: [String] = ["General", "Sports", "Travel", "Weather", "Nature", "Home", "Health", "School", "Creative", "Other"]

    @State private var searchTerm = ""
    @State var accentColor: Color
    @Binding var selectedEmoji: String

    var filteredEmojis: [[String]] {
        guard !searchTerm.isEmpty else { return emojisByCategory }
        return emojisByCategory.map { $0.filter { $0.localizedCaseInsensitiveContains(searchTerm) } }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(filteredEmojis.indices, id: \.self) { index in
                        let categoryEmojis = filteredEmojis[index]
                        if !categoryEmojis.isEmpty {
                            SfSymbolsSectionView(
                                sectionTitle: emojiSectionTitles[index],
                                emojis: categoryEmojis,
                                accentColor: accentColor,
                                selectedEmoji: $selectedEmoji
                            )
                        }
                    }
                }
                .overlay {
                    if filteredEmojis.flatMap({ $0 }).isEmpty {
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView.search(text: searchTerm)
                        } else {
                            Text("No match found")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .navigationTitle("Category Symbols")
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .bold()
                            .foregroundColor(accentColor)
                            .padding(8)
                            .padding(.horizontal, 8)
                            .background(accentColor.opacity(0.16).cornerRadius(20))
                            .accessibilityLabel("Done")
                    }
                }
            })
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        }
        .overlay {
            if filteredEmojis.flatMap({ $0 }).isEmpty {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView.search(text: searchTerm)
                } else {
                    Text("No match found")
                }
            }
        }
    }
}

struct SfSymbolsSectionView: View {
    let sectionTitle: String
    let emojis: [String]
    let accentColor: Color

    @Binding var selectedEmoji: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(sectionTitle)
                .font(.headline)
                .opacity(0.6)
                .padding(.leading, 12)

            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 20
            ) {
                ForEach(emojis.indices, id: \.self) { index in
                    Button(action: {
                        selectedEmoji = emojis[index]
                    }) {
                        Image(systemName: emojis[index])
                            .font(.title)
                            .foregroundColor(selectedEmoji == emojis[index] ? accentColor : .primary)
                            .padding(8)
                            .background(accentColor.opacity(0.16).opacity(selectedEmoji == emojis[index] ? 1 : 0))
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(16)
        }
    }

    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 50, maximum: 50), spacing: 24),
    ]
}

// #Preview {
//    MoreSfSymbolsView()
// }
