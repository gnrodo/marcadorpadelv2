import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var scoreboardModel: ScoreboardModel
    @State private var showingWinnerAlert = false
    @State private var showingSettingsMenu = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    scoreboardModel.backgroundColor(for: colorScheme)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Text("Scoreboard de Pádel")
                                .font(.largeTitle)
                                .padding()
                            Spacer()
                            Button(action: {
                                showingSettingsMenu.toggle()
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(scoreboardModel.textColor(for: colorScheme))
                            }
                            .popover(isPresented: $showingSettingsMenu) {
                                VStack(spacing: 10) {
                                    Button("Cambiar modo") {
                                        scoreboardModel.toggleDarkMode()
                                    }
                                    .buttonStyle(RoundedButtonStyle())
                                    
                                    Button("Cambiar fuente") {
                                        scoreboardModel.changeFont()
                                    }
                                    .buttonStyle(RoundedButtonStyle())
                                    
                                    Button("Cambiar tamaño de fuente") {
                                        scoreboardModel.changeFontSize()
                                    }
                                    .buttonStyle(RoundedButtonStyle())
                                    
                                    Button("Cancelar") {
                                        showingSettingsMenu = false
                                    }
                                    .buttonStyle(RoundedButtonStyle())
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal)

                        VStack {
                            HStack {
                                Text("").frame(width: geometry.size.width * 0.6)
                                ForEach(["Set 1", "Set 2", "Set 3", ""], id: \.self) { header in
                                    Text(header)
                                        .frame(width: geometry.size.width * 0.1)
                                }
                            }
                            .padding(.bottom, 5)
                            
                            VStack(spacing: 0) {
                                ScoreboardRowView(team: .team1, scoreboardModel: scoreboardModel, geometry: geometry)
                                Divider()
                                ScoreboardRowView(team: .team2, scoreboardModel: scoreboardModel, geometry: geometry)
                            }
                            .border(Color.gray, width: 1)
                        }

                        HStack {
                            Button("Deshacer") {
                                scoreboardModel.undo()
                            }
                            .disabled(!scoreboardModel.canUndo)
                            .buttonStyle(RoundedButtonStyle())

                            Button("Reiniciar") {
                                scoreboardModel.resetGame()
                            }
                            .buttonStyle(RoundedButtonStyle())
                        }
                        .padding()
                    }
                    .frame(width: geometry.size.width)
                    .foregroundColor(scoreboardModel.textColor(for: colorScheme))
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
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onChange(of: scoreboardModel.isGameOver) { newValue in
            if newValue {
                showingWinnerAlert = true
            }
        }
        .preferredColorScheme(scoreboardModel.isDarkMode ? .dark : .light)
    }
}

struct ScoreboardRowView: View {
    let team: Team
    @ObservedObject var scoreboardModel: ScoreboardModel
    let geometry: GeometryProxy
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                PlayerView(player: team == .team1 ? $scoreboardModel.team1Player1 : $scoreboardModel.team2Player1)
                PlayerView(player: team == .team1 ? $scoreboardModel.team1Player2 : $scoreboardModel.team2Player2)
            }
            .frame(width: geometry.size.width * 0.6, alignment: .leading)

            ForEach(0..<3) { index in
                VStack {
                    Text("\(scoreboardModel.sets[index][team == .team1 ? 0 : 1])")
                        .frame(width: geometry.size.width * 0.1)
                    if index < 2 {
                        Divider()
                    }
                }
            }

            Text(scoreboardModel.currentScoreString(for: team))
                .frame(width: geometry.size.width * 0.1)
                .foregroundColor(scoreboardModel.isPuntoDeOro ? .yellow : scoreboardModel.textColor(for: colorScheme))
                .onTapGesture {
                    scoreboardModel.updateScore(team: team)
                }
        }
        .padding(.vertical, 5)
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(scoreboardModel: ScoreboardModel())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}