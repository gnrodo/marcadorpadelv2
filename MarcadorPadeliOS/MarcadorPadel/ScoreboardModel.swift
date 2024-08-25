import SwiftUI

struct Player {
    var name: String
    var flag: String
}

enum Team {
    case team1
    case team2
}

class ScoreboardModel: ObservableObject {
    @Published var team1Player1 = Player(name: "Jugador 1", flag: "🇪🇸")
    @Published var team1Player2 = Player(name: "Jugador 2", flag: "🇪🇸")
    @Published var team2Player1 = Player(name: "Jugador 3", flag: "🇪🇸")
    @Published var team2Player2 = Player(name: "Jugador 4", flag: "🇪🇸")
    
    @Published var currentScores = [0, 0]
    @Published var sets = [[0, 0], [0, 0], [0, 0]]
    @Published var currentSet = 0
    @Published var isGameOver = false
    @Published var isTiebreak = false
    @Published var winnerMessage = ""
    
    @Published var isDarkMode = false
    @Published var currentFont = "Roboto"
    @Published var currentFontSize: CGFloat = 16
    
    private let scores = ["0", "15", "30", "40", "AD"]
    private var history: [GameState] = []
    
    var canUndo: Bool {
        !history.isEmpty
    }
    
    var isPuntoDeOro: Bool {
        currentScores[0] == 3 && currentScores[1] == 3 && !isTiebreak
    }
    
    func updateScore(team: Team) {
        if isGameOver { return }
        
        let teamIndex = team == .team1 ? 0 : 1
        let otherTeamIndex = 1 - teamIndex
        
        history.append(GameState(currentScores: currentScores, sets: sets, currentSet: currentSet, isTiebreak: isTiebreak))
        
        if isTiebreak {
            currentScores[teamIndex] += 1
            if currentScores[teamIndex] >= 7 && currentScores[teamIndex] - currentScores[otherTeamIndex] >= 2 {
                winTiebreak(team: team)
            }
        } else {
            if currentScores[teamIndex] == 3 && currentScores[otherTeamIndex] == 3 {
                // Punto de oro
                winGame(team: team)
            } else if currentScores[teamIndex] == 3 && currentScores[otherTeamIndex] < 3 {
                winGame(team: team)
            } else if currentScores[teamIndex] == 4 {
                winGame(team: team)
            } else {
                currentScores[teamIndex] += 1
            }
        }
    }
    
    private func winGame(team: Team) {
        let teamIndex = team == .team1 ? 0 : 1
        sets[currentSet][teamIndex] += 1
        if sets[currentSet][0] == 6 && sets[currentSet][1] == 6 {
            isTiebreak = true
            currentScores = [0, 0]
        } else if sets[currentSet][teamIndex] >= 6 && sets[currentSet][teamIndex] - sets[currentSet][1 - teamIndex] >= 2 {
            winSet(team: team)
        } else {
            currentScores = [0, 0]
        }
    }
    
    private func winTiebreak(team: Team) {
        let teamIndex = team == .team1 ? 0 : 1
        sets[currentSet][teamIndex] = 7
        sets[currentSet][1 - teamIndex] = 6
        winSet(team: team)
    }
    
    private func winSet(team: Team) {
        isTiebreak = false
        currentScores = [0, 0]
        
        let teamIndex = team == .team1 ? 0 : 1
        let setsWon = sets.filter { $0[teamIndex] > $0[1 - teamIndex] }.count
        
        if setsWon == 2 {
            isGameOver = true
            let winnerNames = team == .team1 ? [team1Player1.name, team1Player2.name] : [team2Player1.name, team2Player2.name]
            winnerMessage = "¡\(winnerNames[0]) y \(winnerNames[1]) ganan el partido!"
        } else {
            currentSet += 1
        }
    }
    
    func undo() {
        guard let lastState = history.popLast() else { return }
        currentScores = lastState.currentScores
        sets = lastState.sets
        currentSet = lastState.currentSet
        isTiebreak = lastState.isTiebreak
        isGameOver = false
        winnerMessage = ""
    }
    
    func resetGame() {
        currentScores = [0, 0]
        sets = [[0, 0], [0, 0], [0, 0]]
        currentSet = 0
        isGameOver = false
        isTiebreak = false
        winnerMessage = ""
        history.removeAll()
    }
    
    func currentScoreString(for team: Team) -> String {
        let index = team == .team1 ? 0 : 1
        return isTiebreak ? "\(currentScores[index])" : scores[currentScores[index]]
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    func changeFont() {
        let fonts = ["Roboto", "Open Sans", "Lato", "Montserrat"]
        if let currentIndex = fonts.firstIndex(of: currentFont) {
            currentFont = fonts[(currentIndex + 1) % fonts.count]
        }
    }
    
    func changeFontSize() {
        currentFontSize = currentFontSize == 16 ? 18 : 16
    }
}

struct GameState {
    let currentScores: [Int]
    let sets: [[Int]]
    let currentSet: Int
    let isTiebreak: Bool
}