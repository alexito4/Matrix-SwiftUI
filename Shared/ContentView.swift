import SwiftUI

struct ColumnData: Identifiable {
    let id = UUID()
    let characters: [Character]
    let glyphSize: Int
    let x: Double
    let speed: Double

    init(_: GeometryProxy, x: Double) {
        characters = repeatElement((), count: (10...30).randomElement()!)
            .map { glyphs.randomElement()! }
        self.x = x
        glyphSize = Int.random(in: 15...22)
        speed = Double.random(in: 30.0...90.0)
    }

    static func columns(_ proxy: GeometryProxy) -> [ColumnData] {
        let estimatedColumnWidth = 26.0
        let width = proxy.size.width

        let count = Int(width / estimatedColumnWidth)
        return (0..<count).map { i in
            ColumnData(
                proxy,
                x: (Double(i) * estimatedColumnWidth) + (estimatedColumnWidth / 4)
            )
        }
    }
}

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            let columnsData = ColumnData.columns(proxy)

            Matrix(data: columnsData, fullHeight: proxy.size.height)
        }
        .clipped()
    }
}

struct Matrix: View {
    let data: [ColumnData]
    let fullHeight: CGFloat

    var body: some View {
        TimelineView(.animation) { ctx in
            ZStack(alignment: .topLeading) {
                ForEach(data) { data in
                    Column(fullHeight: fullHeight, data: data, tick: ctx.date.timeIntervalSinceReferenceDate)
                }

                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct Column: View {
    let fullHeight: CGFloat
    let data: ColumnData
    let tick: TimeInterval
    @State var columnHeight: CGFloat = 0

    var body: some View {
        VStack {
            ForEach(Array(data.characters.enumerated()), id: \.offset) { _, character in
                Glyph(character: character)
            }
        }
        .readSize { columnHeight = $0.height }
        .font(.system(size: CGFloat(data.glyphSize)).monospaced())
        .offset(x: data.x)
        .offset(y: (tick * data.speed).truncatingRemainder(dividingBy: fullHeight + columnHeight) - columnHeight)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize = .zero
    fileprivate static func reduce(value _: inout CGSize, nextValue _: () -> CGSize) {}
}

public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

let glyphs: [Character] = [
    "0", "1", // "2","3","4","5","6","7","8","9",
]

struct Glyph: View {
    let character: Character
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.5, paused: false)) { _ in
            let pickRandom = Int.random(in: 0...100) < 2
            Text(String(pickRandom ? glyphs.randomElement()! : character))
                .foregroundColor(.matrix)
//                .shadow(color: .matrix, radius: pickRandom ? 10 : 0, x: 0, y: 0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .padding(.vertical, 10)
    }
}

extension Color {
    static let matrix = Color(red: 3 / 255, green: 160 / 255, blue: 98 / 255)
}
