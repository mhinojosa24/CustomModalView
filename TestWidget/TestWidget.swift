//
//  TestWidget.swift
//  TestWidget
//
//  Created by Maximo Hinojosa on 11/1/20.
//

import WidgetKit
import SwiftUI

class MyDateProvider {
    
    static func getRandomString() -> String {
        let strings: [String] = [
            "One",
            "Two",
            "Three",
            "Four",
            "Five",
            "Six",
            "Seven",
            "Eight",
            "Nine",
            "Ten"
        ]
        return strings.randomElement() ?? "Zero"
    }
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), myString: "...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), myString: "...")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, myString: MyDateProvider.getRandomString())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let myString: String
}

struct TestWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text("cobble")
                .foregroundColor(Color.init(#colorLiteral(red: 0.9455459714, green: 0.795925796, blue: 0.04932839423, alpha: 1)))
                .fontWeight(.medium)
                .font(.system(size: 14))
            
            Text(entry.myString)
                .foregroundColor(.black)
                .fontWeight(.regular)
        }).foregroundColor(Color(#colorLiteral(red: 0.9179172552, green: 0.9270055448, blue: 0.9270055448, alpha: 1)))
    }
}

@main
struct TestWidget: Widget {
    let kind: String = "TestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TestWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TestWidget_Previews: PreviewProvider {
    static var previews: some View {
        TestWidgetEntryView(entry: SimpleEntry(date: Date(), myString: "..."))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
