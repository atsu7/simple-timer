import SwiftUI
import AppKit

@MainActor
final class TimerModel: ObservableObject {
    @Published var minutes = 5
    @Published var seconds = 0
    @Published var remaining: TimeInterval = 300
    @Published var running = false
    @Published var finished = false
    @Published var pinned = false
    private var deadline: Date?
    private var ticker: Timer?

    var display: String {
        let value = max(0, Int(ceil(remaining)))
        return String(format: "%02d:%02d", value / 60, value % 60)
    }

    func reset() {
        ticker?.invalidate()
        ticker = nil
        deadline = nil
        running = false
        finished = false
        remaining = TimeInterval(minutes * 60 + seconds)
    }

    func toggle() {
        if running {
            remaining = max(0, deadline?.timeIntervalSinceNow ?? remaining)
            running = false
            ticker?.invalidate()
            ticker = nil
            deadline = nil
        } else {
            if remaining <= 0 { reset() }
            guard remaining > 0 else { return }
            finished = false
            deadline = Date().addingTimeInterval(remaining)
            running = true
            ticker = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.tick() }
            }
        }
    }

    private func tick() {
        guard running, let deadline else { return }
        remaining = max(0, deadline.timeIntervalSinceNow)
        if remaining <= 0 {
            ticker?.invalidate()
            ticker = nil
            self.deadline = nil
            running = false
            finished = true
            NSSound(named: "Glass")?.play()
            NSApp.requestUserAttention(.informationalRequest)
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    var pinned: Bool
    func makeNSView(context: Context) -> NSView { NSView() }
    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async {
            view.window?.level = pinned ? .floating : .normal
            view.window?.collectionBehavior = [.fullScreenAuxiliary]
        }
    }
}

struct ContentView: View {
    @StateObject private var model = TimerModel()
    @AppStorage("timerTitle") private var timerTitle = "Timer"

    private func timeBinding(_ keyPath: ReferenceWritableKeyPath<TimerModel, Int>, maximum: Int) -> Binding<String> {
        Binding(
            get: { String(model[keyPath: keyPath]) },
            set: { text in
                let digits = String(text.filter { $0.isASCII && $0.isNumber }.prefix(3))
                model[keyPath: keyPath] = min(maximum, Int(digits) ?? 0)
                model.reset()
            }
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Timer name", text: $timerTitle)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                    .accessibilityLabel("Timer name")
                Spacer()
                Button {
                    model.pinned.toggle()
                } label: {
                    Image(systemName: model.pinned ? "pin.fill" : "pin")
                        .foregroundStyle(model.pinned ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
                .help(model.pinned ? "Disable Always on Top" : "Always on Top")
                .accessibilityLabel(model.pinned ? "Disable Always on Top" : "Always on Top")
            }

            Text(model.display)
                .font(.system(size: 68, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(model.finished ? Color.accentColor : Color.primary)
                .contentTransition(.numericText(countsDown: true))
                .accessibilityLabel("Time remaining \(model.display)")

            HStack(spacing: 8) {
                TextField("min", text: timeBinding(\.minutes, maximum: 999))
                    .accessibilityLabel("min")
                    .frame(width: 64)
                Text("min")
                TextField("sec", text: timeBinding(\.seconds, maximum: 59))
                    .accessibilityLabel("sec")
                    .frame(width: 54)
                Text("sec")
            }
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            .disabled(model.running)

            HStack(spacing: 12) {
                Button("Reset") { model.reset() }
                    .keyboardShortcut("r", modifiers: .command)
                Button(model.running ? "Pause" : "Start") { model.toggle() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.space, modifiers: [])
                    .disabled(!model.running && model.minutes == 0 && model.seconds == 0)
            }
            .controlSize(.large)
        }
        .padding(24)
        .frame(minWidth: 280, maxWidth: .infinity, minHeight: 250, maxHeight: .infinity)
        .background(WindowAccessor(pinned: model.pinned))
        .onAppear {
            if timerTitle == "タイマー" { timerTitle = "Timer" }
        }
    }
}

@main
struct SimpleTimerApp: App {
    var body: some Scene {
        Window("Simple Timer", id: "timer") {
            ContentView()
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 348, height: 300)
        .defaultPosition(.center)
        .commands { CommandGroup(replacing: .newItem) {} }
    }
}
