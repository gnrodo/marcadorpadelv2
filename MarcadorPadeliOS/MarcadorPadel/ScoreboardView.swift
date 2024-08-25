import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var scoreboardModel: ScoreboardModel
    @State private var showingWinnerAlert = false
    @State private var showingSettingsMenu = false

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    scoreboardModel.backgroundColor
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
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
                                    .foregroundColor(scoreboardModel.textColor)
                            }
                            .popover(isPresented: $showingSettingsMenu) {
                                ZStack {
                                    scoreboardModel.backgroundColor
                                        .edgesIgnoringSafeArea(.all)
                                    
                                    VStack(spacing: 15) {
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
                                    .foregroundColor(scoreboardModel.textColor)
                                }
                            }
                        }
                        .padding(.horizontal)

                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("").frame(width: geometry.size.width * 0.6)
                                ForEach(["Set 1", "Set 2", "Set 3", ""], id: \.self) { header in
                                    Text(header)
                                        .frame(width: geometry.size.width * 0.1)
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                            .padding(.bottom, 5)
                            
                            VStack(spacing: 0) {
                                ScoreboardRowView(team: .team1, scoreboardModel: scoreboardModel, geometry: geometry)
                                Divider()
                                    .background(scoreboardModel.tableBorderColor)
                                ScoreboardRowView(team: .team2, scoreboardModel: scoreboardModel, geometry: geometry)
                            }
                            .background(scoreboardModel.tableBackgroundColor)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(scoreboardModel.tableBorderColor, lineWidth: 1)
                            )
                        }

                        HStack(spacing: 20) {
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
                    .foregroundColor(scoreboardModel.textColor)
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
    }
}

struct ScoreboardRowView: View {
    let team: Team
    @ObservedObject var scoreboardModel: ScoreboardModel
    let geometry: GeometryProxy

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 5) {
                PlayerView(player: team == .team1 ? $scoreboardModel.team1Player1 : $scoreboardModel.team2Player1)
                PlayerView(player: team == .team1 ? $scoreboardModel.team1Player2 : $scoreboardModel.team2Player2)
            }
            .frame(width: geometry.size.width * 0.6, alignment: .leading)
            .padding(.vertical, 5)

            ForEach(0..<4) { index in
                if index > 0 {
                    Divider().frame(height: 70)
                        .background(scoreboardModel.tableBorderColor)
                }
                if index < 3 {
                    Text("\(scoreboardModel.sets[index][team == .team1 ? 0 : 1])")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: geometry.size.width * 0.1, height: 70)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(scoreboardModel.isPuntoDeOro ? Color.yellow : Color.clear)
                        Text(scoreboardModel.currentScoreString(for: team))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(scoreboardModel.textColor)
                    }
                    .frame(width: geometry.size.width * 0.1, height: 70)
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