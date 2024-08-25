import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var scoreboardModel: ScoreboardModel
    @State private var showingWinnerAlert = false
    @State private var showingSettingsMenu = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
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
                                    scoreboardModel.toggleDarkMode()
                                },
                                .default(Text("Cambiar fuente")) {
                                    scoreboardModel.changeFont()
                                },
                                .default(Text("Cambiar tamaño de fuente")) {
                                    scoreboardModel.changeFontSize()
                                },
                                .cancel()
                            ])
                        }
                    }
                    .padding(.horizontal)

                    Text("Scoreboard de Pádel")
                        .font(.largeTitle)
                        .padding()

                    HStack {
                        Text("").frame(width: 150)
                        ForEach(["Set 1", "Set 2", "Set 3", "Puntos"], id: \.self) { header in
                            Text(header)
                                .frame(width: 60)
                        }
                    }

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
                .frame(width: geometry.size.width)
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
                    .frame(width: 60)
            }

            Text(scoreboardModel.currentScoreString(for: team))
                .frame(width: 60)
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