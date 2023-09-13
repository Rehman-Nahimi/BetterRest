//
//  ContentView.swift
//  BetterRest
//
//  Created by Ray Nahimi on 04/09/2023.
//
import CoreML
import SwiftUI


struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    
    var body: some View {
        NavigationView{
            
            
            Form {
                VStack(alignment: .leading, spacing: 0){
                    
                    
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) {newValue in calculateBedTime() }
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) {newValue in calculateBedTime() }
                }
                VStack(alignment: .leading, spacing: 0){
                    Text("How much coffee did you drink")
                        .font(.headline)
                    
                    Stepper("\(coffeeAmount.formatted()) cups" , value: $coffeeAmount, in: 0...20, step: 1)
                        .onChange(of: coffeeAmount) {newValue in calculateBedTime() }
                
                }
                VStack(alignment: .center, spacing: 50){
                    Text("Your bed time is: \(alertMessage)")
                        .frame(maxWidth: .infinity)
                        .font(.subheadline.weight(.heavy))
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok") {}
            }message: {
                Text(alertMessage)
            }
            
        }
    }
    func calculateBedTime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount) )
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your Ideal Bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time:.shortened)
        } catch{
            alertTitle = "Error"
            alertMessage = "There was a problem calculating your bedtime"
        }
        showingAlert = true
    }
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

