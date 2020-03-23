//
//  ContentView.swift
//  UserDefaultsExample
//
//  Created by Nien Lam on 3/23/20.
//  Copyright © 2020 Mobile Lab. All rights reserved.
//

import SwiftUI

// Constant used as key for saving and loading data from User Defaults.
let KeyForUserDefaults = "MY_DATA_KEY"


// Simple data structure.
// NOTE: Required Codable protocol.
struct MyData: Codable {
    let id = UUID()
    var msg: String
    var date: Date
}


// View Model.
class AppModel: ObservableObject {
    // Array of saved data.
    @Published var myDataArray = [MyData]()
    
    init() {
        //// LOAD DATA FROM USER DEFAULTS //
        loadData()
    }
    
    // Method to save myDataArray.
    func saveData() {
        let data = myDataArray.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: KeyForUserDefaults)
    }
 
    // Method to load myDataArray.
    func loadData() {
        guard let encodedData = UserDefaults.standard.array(forKey: KeyForUserDefaults) as? [Data] else {
            return
        }
        myDataArray = encodedData.map { try! JSONDecoder().decode(MyData.self, from: $0) }
    }
    
    // Add message to data array.
    func addMessage(msg: String) {
        let myData = MyData(msg: msg.isEmpty ? "Empty Message" : msg, date: Date())
        myDataArray.append(myData)

        //// SAVE DATA TO USER DEFAULTS //
        saveData()
    }
}


struct ContentView: View {
    @ObservedObject var appModel = AppModel()
    
    @State var msg: String = ""
    
    var body: some View {
        VStack {
            // Input text field and button.
            HStack {
                TextField("Enter a message", text: $msg)
                    .font(.system(size: 30))
                    .padding(6)
                    .border(Color.orange, width: 2)
                
                Button(action: {
                    self.appModel.addMessage(msg: self.msg)
                    self.msg = ""
                }) {
                    Image(systemName: "plus.square.fill")
                        .font(.system(size: 48))
                }
                .buttonStyle(PlainButtonStyle())
                
            }
            .padding()

            // Scroll view of data.
            ScrollView() {
                VStack {
                    ForEach(appModel.myDataArray, id: \.id) { myData in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(myData.msg)
                                .font(.system(.body))
                            Text("\(myData.date)")
                                .font(.system(.caption))
                                .foregroundColor(.gray)
                        }
                        .padding(4)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
