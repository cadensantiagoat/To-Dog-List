//
//  SettingsView.swift
//  To-Dog-List
//
//  Created by Michael on 4/21/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)

            Text("Settings")
                .font(.title)
                .fontWeight(.bold)

            Text("Settings page coming soon.")
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
