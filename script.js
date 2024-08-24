document.addEventListener('DOMContentLoaded', () => {
    const team1Score = document.querySelector('.team1 .current-score');
    const team2Score = document.querySelector('.team2 .current-score');
    const addPointButtons = document.querySelectorAll('.add-point');
    const undoButton = document.getElementById('undo');
    const resetButton = document.getElementById('reset');
    const flagIcons = document.querySelectorAll('.flag-icon');
    const playerNames = document.querySelectorAll('.player-name');

    const scores = ['0', '15', '30', '40', 'AD'];
    let currentScores = [0, 0];
    let sets = [[0, 0], [0, 0], [0, 0]];
    let currentSet = 0;
    let history = [];

    function updateScore(team) {
        history.push({currentScores: [...currentScores], sets: JSON.parse(JSON.stringify(sets)), currentSet});
        
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

        // Highlight cells if score is 40-40
        if (currentScores[0] === 3 && currentScores[1] === 3) {
            team1Score.classList.add('golden');
            team2Score.classList.add('golden');
        } else {
            team1Score.classList.remove('golden');
            team2Score.classList.remove('golden');
        }
    }

    function undo() {
        if (history.length > 0) {
            const lastState = history.pop();
            currentScores = lastState.currentScores;
            sets = lastState.sets;
            currentSet = lastState.currentSet;
            updateScoreboard();
        }
    }

    function resetGame() {
        currentScores = [0, 0];
        sets = [[0, 0], [0, 0], [0, 0]];
        currentSet = 0;
        history = [];
        updateScoreboard();
    }

    addPointButtons.forEach((button) => {
        button.addEventListener('click', () => {
            const team = parseInt(button.getAttribute('data-team')) - 1;
            updateScore(team);
        });
    });

    undoButton.addEventListener('click', undo);
    resetButton.addEventListener('click', resetGame);

    flagIcons.forEach(flag => {
        flag.addEventListener('click', () => {
            const team = flag.getAttribute('data-team');
            const player = flag.getAttribute('data-player');
            const newCountry = prompt('Ingrese el código de país de 2 letras (ej. es, ar, us):');
            if (newCountry && newCountry.length === 2) {
                flag.className = `flag-icon flag-icon-${newCountry.toLowerCase()}`;
            }
        });
    });

    playerNames.forEach(name => {
        name.addEventListener('blur', () => {
            if (name.textContent.trim() === '') {
                name.textContent = `Jugador ${name.getAttribute('data-team')}${name.getAttribute('data-player')}`;
            }
        });
    });

    updateScoreboard();
});