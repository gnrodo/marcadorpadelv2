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
                                    .buttonStyle(RedButtonStyle())
                                    
                                    Button("Cambiar fuente") {
                                        scoreboardModel.changeFont()
                                    }
                                    .buttonStyle(RedButtonStyle())
                                    
                                    Button("Cambiar tamaño de fuente") {
                                        scoreboardModel.changeFontSize()
                                    }
                                    .buttonStyle(RedButtonStyle())
                                    
                                    Button("Volver") {
                                        showingSettingsMenu = false
                                    }
                                    .buttonStyle(RedButtonStyle())
                                }
                                .padding()
                                .background(scoreboardModel.backgroundColor(for: scoreboardModel.isDarkMode ? .dark : .light))
                                .foregroundColor(scoreboardModel.textColor(for: scoreboardModel.isDarkMode ? .dark : .light))
                            }
                        }
                        .padding(.horizontal)

                        VStack {
                            HStack(spacing: 0) {
                                Text("").frame(width: geometry.size.width * 0.6)
                                ForEach(["Set 1", "Set 2", "Set 3", ""], id: \.self) { header in
                                    Text(header)
                                        .frame(width: geometry.size.width * 0.1)
                                }
                            }
                            .padding(.bottom, 5)
                            
                            VStack(spacing: 0) {
                                ScoreboardRowView(team: .team1, scoreboardModel: scoreboardModel, geometry: geometry)
                                    .padding(.vertical, 10)
                                Divider()
                                    .background(scoreboardModel.tableBorderColor(for: colorScheme))
                                ScoreboardRowView(team: .team2, scoreboardModel: scoreboardModel, geometry: geometry)
                                    .padding(.vertical, 10)
                            }
                            .background(scoreboardModel.tableBackgroundColor(for: colorScheme))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(scoreboardModel.tableBorderColor(for: colorScheme), lineWidth: 1)
                            )
                        }

                        HStack {
                            Button("Deshacer") {
                                scoreboardModel.undo()
                            }
                            .disabled(!scoreboardModel.canUndo)
                            .buttonStyle(RedButtonStyle())

                            Button("Reiniciar") {
                                scoreboardModel.resetGame()
                            }
                            .buttonStyle(RedButtonStyle())
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

            ForEach(0..<4) { index in
                if index > 0 {
                    Divider().frame(height: 50)
                        .background(scoreboardModel.tableBorderColor(for: colorScheme))
                }
                if index < 3 {
                    Text("\(scoreboardModel.sets[index][team == .team1 ? 0 : 1])")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: geometry.size.width * 0.1)
                } else {
                    ZStack {
                        if scoreboardModel.isPuntoDeOro {
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: geometry.size.width * 0.1, height: 50)
                        }
                        Text(scoreboardModel.currentScoreString(for: team))
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: geometry.size.width * 0.1)
                            .foregroundColor(scoreboardModel.textColor(for: colorScheme))
                    }
                    .onTapGesture {
                        scoreboardModel.updateScore(team: team)
                    }
                }
            }
        }
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(scoreboardModel: ScoreboardModel())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}