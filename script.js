document.addEventListener('DOMContentLoaded', () => {
    const team1Score = document.querySelector('.team1 .current-score');
    const team2Score = document.querySelector('.team2 .current-score');
    const addPointButtons = document.querySelectorAll('.add-point');
    const resetButton = document.getElementById('reset');

    const scores = ['0', '15', '30', '40', 'AD'];
    let currentScores = [0, 0];
    let sets = [[0, 0], [0, 0], [0, 0]];
    let currentSet = 0;

    function updateScore(team) {
        const otherTeam = team === 0 ? 1 : 0;
        
        if (currentScores[team] === 3 && currentScores[otherTeam] === 3) {
            // Punto de oro
            winGame(team);
        } else if (currentScores[team] === 3 && currentScores[otherTeam] < 3) {
            winGame(team);
        } else if (currentScores[team] === 4) {
            winGame(team);
        } else {
            currentScores[team]++;
        }

        updateScoreboard();
    }

    function winGame(team) {
        sets[currentSet][team]++;
        if (sets[currentSet][team] >= 6 && sets[currentSet][team] - sets[currentSet][1 - team] >= 2) {
            winSet(team);
        } else if (sets[currentSet][team] === 7) {
            winSet(team);
        }
        currentScores = [0, 0];
        updateScoreboard();
    }

    function winSet(team) {
        currentSet++;
        if (currentSet === 3 || (currentSet === 2 && sets[0][team] === 1)) {
            // Game over, team wins
            alert(`¡El Equipo ${team + 1} gana el partido!`);
        }
    }

    function updateScoreboard() {
        team1Score.textContent = scores[currentScores[0]];
        team2Score.textContent = scores[currentScores[1]];

        for (let i = 0; i < 3; i++) {
            document.querySelector(`.team1 .set${i + 1}`).textContent = sets[i][0];
            document.querySelector(`.team2 .set${i + 1}`).textContent = sets[i][1];
        }
    }

    function resetGame() {
        currentScores = [0, 0];
        sets = [[0, 0], [0, 0], [0, 0]];
        currentSet = 0;
        updateScoreboard();
    }

    addPointButtons.forEach((button) => {
        button.addEventListener('click', () => {
            const team = parseInt(button.getAttribute('data-team')) - 1;
            updateScore(team);
        });
    });

    resetButton.addEventListener('click', resetGame);

    updateScoreboard();
});