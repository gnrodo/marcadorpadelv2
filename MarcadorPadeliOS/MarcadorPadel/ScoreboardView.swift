import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var scoreboardModel: ScoreboardModel
    @State private var showingWinnerAlert = false
    
    var body: some View {
        VStack {
            Text("Marcador de Pádel")
                .font(.largeTitle)
                .padding()
            
            HStack {
                VStack {
                    PlayerView(player: $scoreboardModel.team1Player1)
                    PlayerView(player: $scoreboardModel.team1Player2)
                }
                VStack {
                    PlayerView(player: $scoreboardModel.team2Player1)
                    PlayerView(player: $scoreboardModel.team2Player2)
                }
            }
            
            HStack {
                VStack {
                    Text("Equipo 1")
                    Text("Set 1: \(scoreboardModel.sets[0][0])")
                    Text("Set 2: \(scoreboardModel.sets[1][0])")
                    Text("Set 3: \(scoreboardModel.sets[2][0])")
                    Text("Puntos: \(scoreboardModel.currentScores[0])")
                    Button("Punto Equipo 1") {
                        scoreboardModel.updateScore(team: 0)
                        checkForWinner()
                    }
                }
                VStack {
                    Text("Equipo 2")
                    Text("Set 1: \(scoreboardModel.sets[0][1])")
                    Text("Set 2: \(scoreboardModel.sets[1][1])")
                    Text("Set 3: \(scoreboardModel.sets[2][1])")
                    Text("Puntos: \(scoreboardModel.currentScores[1])")
                    Button("Punto Equipo 2") {
                        scoreboardModel.updateScore(team: 1)
                        checkForWinner()
                    }
                }
            }
            
            Button("Reiniciar Juego") {
                scoreboardModel.resetGame()
            }
            .padding()
        }
        .alert(isPresented: $showingWinnerAlert) {
            Alert(
                title: Text("¡Fin del Partido!"),
                message: Text(scoreboardModel.winnerMessage),
                dismissButton: .default(Text("OK")) {
                    scoreboardModel.resetGame()
                }
            )
        }
    }
    
    private func checkForWinner() {
        if scoreboardModel.isGameOver {
            showingWinnerAlert = true
        }
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(scoreboardModel: ScoreboardModel())
    }
}