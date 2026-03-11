import Foundation

// MARK: - Date helpers
extension Date {
    var dayMonthYear: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MM/dd/yyyy"
        return f.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isSameDayOfYear: Bool {
        let cal = Calendar.current
        let today = Date()
        return cal.component(.month, from: self) == cal.component(.month, from: today) &&
               cal.component(.day, from: self)   == cal.component(.day, from: today)
    }

    /// Days until next birthday (ignoring year)
    func daysUntilBirthday() -> Int {
        let cal = Calendar.current
        let today = Date()
        var comps = cal.dateComponents([.month, .day], from: self)
        comps.year = cal.component(.year, from: today)
        var next = cal.date(from: comps) ?? today
        if next < today {
            comps.year! += 1
            next = cal.date(from: comps) ?? today
        }
        return cal.dateComponents([.day], from: today, to: next).day ?? 0
    }
}

// MARK: - Double formatting
extension Double {
    var currencyString: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "$"
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
