//Sanyog Dani from SRM Chennai, India

//MyAlarmy is an innovative alarm clock app designed to ensure you wake up fully alert by requiring a math solution to stop the alarm. Instead of a simple snooze button, users must solve a math problem to turn off the alarm, preventing oversleeping and improving cognitive function in the morning.

import SwiftUI
import AVFoundation
import PlaygroundSupport

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var alarmTime = Date()
    @State private var isAlarmSet = false
    @State private var isAlarmTriggered = false
    @State private var mathProblem = ""
    @State private var userAnswer = ""
    @State private var correctAnswer = 0
    @State private var audioPlayer: AVAudioPlayer?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Current Time: \(currentTime, formatter: timeFormatter)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                    .padding(.top, 40)
                
                if !isAlarmTriggered {
                    DatePicker("Set Alarm", selection: $alarmTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    
                    Button(action: setAlarm) {
                        Text(isAlarmSet ? "Alarm Set" : "Set Alarm")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isAlarmSet ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                            .scaleEffect(isAlarmSet ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isAlarmSet)
                    }
                    .disabled(isAlarmSet)
                } else {
                    VStack(spacing: 20) {
                        Text("WakeUp! Answer to stop:")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                        
                        Text(mathProblem)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                        
                        TextField("Your Answer", text: $userAnswer)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        Button(action: checkAnswer) {
                            Text("Submit")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                                .scaleEffect(userAnswer.isEmpty ? 1.0 : 1.05)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: userAnswer)
                        }
                    }
                    .padding()
                    .transition(.opacity)
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
            if isAlarmSet && !isAlarmTriggered && isAlarmTimeReached() {
                triggerAlarm()
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    
    func setAlarm() {
        isAlarmSet = true
        isAlarmTriggered = false
        userAnswer = ""
        mathProblem = ""
    }
    
    func isAlarmTimeReached() -> Bool {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentTime)
        let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarmTime)
        return currentComponents.hour == alarmComponents.hour &&
        currentComponents.minute == alarmComponents.minute
    }
    
    func triggerAlarm() {
        isAlarmTriggered = true
        generateMathProblem()
        playSound()
    }
    
    func generateMathProblem() {
        let num1 = Int.random(in: 1...10)
        let num2 = Int.random(in: 1...10)
        correctAnswer = num1 * num2
        mathProblem = "\(num1) × \(num2) = ?"
    }
    
    func checkAnswer() {
        if let answer = Int(userAnswer), answer == correctAnswer {
            stopAlarm()
        } else {
            userAnswer = ""
        }
    }
    
    func playSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            if let path = Bundle.main.path(forResource: "mixkit-alarm-tone-996", ofType: "wav") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func stopAlarm() {
        audioPlayer?.stop()
        isAlarmTriggered = false
        isAlarmSet = false
    }
}

PlaygroundPage.current.setLiveView(ContentView())
PlaygroundPage.current.needsIndefiniteExecution = true
