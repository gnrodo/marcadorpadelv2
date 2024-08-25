import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var scoreboardModel: ScoreboardModel
    @State private var showingWinnerAlert = false
    @State private var showingSettingsMenu = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showingSettingsMenu.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                    .actionSheet(isPresented: $showingSettingsMenu) {
                        ActionSheet(title: Text("Ajustes"), buttons: [
                            .default(Text("Cambiar modo")) {
                                // Toggle dark mode
                            },
                            .default(Text("Cambiar fuente")) {
                                // Change font
                            },
                            .default(Text("Cambiar tamaño de fuente")) {
                                // Change font size
                            },
                            .cancel()
                        ])
                    }
                }
                .padding(.horizontal)

                Text("Scoreboard de Pádel")
                    .font(.largeTitle)
                    .padding()

                VStack(spacing: 20) {
                    ScoreboardRowView(team: .team1, scoreboardModel: scoreboardModel)
                    ScoreboardRowView(team: .team2, scoreboardModel: scoreboardModel)
                }

                HStack {
                    Button("Deshacer") {
                        scoreboardModel.undo()
                    }
                    .disabled(!scoreboardModel.canUndo)

                    Button("Reiniciar Juego") {
                        scoreboardModel.resetGame()
                    }
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
        .onChange(of: scoreboardModel.isGameOver) { newValue in
            if newValue {
                showingWinnerAlert = true
            }
        }
    }
}

struct ScoreboardRowView: View {
    let team: Team
    @ObservedObject var scoreboardModel: ScoreboardModel

    var body: some View {
        HStack {
            VStack {
                PlayerView(player: team == .team1 ? $scoreboardModel.team1Player1 : $scoreboardModel.team2Player1)
                PlayerView(player: team == .team1 ? $scoreboardModel.team1Player2 : $scoreboardModel.team2Player2)
            }
            .frame(width: 150, alignment: .leading)

            ForEach(0..<3) { index in
                Text("\(scoreboardModel.sets[index][team == .team1 ? 0 : 1])")
                    .frame(width: 40)
            }

            Text(scoreboardModel.currentScoreString(for: team))
                .frame(width: 40)
                .foregroundColor(scoreboardModel.isPuntoDeOro ? .yellow : .primary)
                .onTapGesture {
                    scoreboardModel.updateScore(team: team)
                }
        }
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(scoreboardModel: ScoreboardModel())
    }
}