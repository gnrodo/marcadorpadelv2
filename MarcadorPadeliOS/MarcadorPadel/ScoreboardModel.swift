import Foundation

struct Player {
    var name: String
    var flag: String
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
    
    private let scores = ["0", "15", "30", "40", "AD"]
    
    func updateScore(team: Int) {
        let otherTeam = 1 - team
        
        if isTiebreak {
            currentScores[team] += 1
            if currentScores[team] >= 7 && currentScores[team] - currentScores[otherTeam] >= 2 {
                winTiebreak(team: team)
            }
        } else {
            if currentScores[team] == 3 && currentScores[otherTeam] == 3 {
                // Punto de oro
                winGame(team: team)
            } else if currentScores[team] == 3 && currentScores[otherTeam] < 3 {
                winGame(team: team)
            } else if currentScores[team] == 4 {
                winGame(team: team)
            } else {
                currentScores[team] += 1
            }
        }
    }
    
    private func winGame(team: Int) {
        sets[currentSet][team] += 1
        if sets[currentSet][0] == 6 && sets[currentSet][1] == 6 {
            isTiebreak = true
            currentScores = [0, 0]
        } else if sets[currentSet][team] >= 6 && sets[currentSet][team] - sets[currentSet][1 - team] >= 2 {
            winSet(team: team)
        } else {
            currentScores = [0, 0]
        }
    }
    
    private func winTiebreak(team: Int) {
        sets[currentSet][team] = 7
        sets[currentSet][1 - team] = 6
        winSet(team: team)
    }
    
    private func winSet(team: Int) {
        isTiebreak = false
        currentScores = [0, 0]
        
        let setsWon = sets.filter { $0[team] > $0[1 - team] }.count
        
        if setsWon == 2 {
            isGameOver = true
            let winnerNames = team == 0 ? [team1Player1.name, team1Player2.name] : [team2Player1.name, team2Player2.name]
            winnerMessage = "¡\(winnerNames[0]) y \(winnerNames[1]) ganan el partido!"
        } else {
            currentSet += 1
        }
    }
    
    func resetGame() {
        currentScores = [0, 0]
        sets = [[0, 0], [0, 0], [0, 0]]
        currentSet = 0
        isGameOver = false
        isTiebreak = false
        winnerMessage = ""
    }
}