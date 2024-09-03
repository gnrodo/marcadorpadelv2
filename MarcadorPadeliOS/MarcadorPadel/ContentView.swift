import SwiftUI

struct ContentView: View {
    @StateObject private var scoreboardModel = ScoreboardModel()
    
    var body: some View {
        ScoreboardView(scoreboardModel: scoreboardModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}