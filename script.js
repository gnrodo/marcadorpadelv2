document.addEventListener('DOMContentLoaded', () => {
    const team1Score = document.querySelector('.team1 .current-score');
    const team2Score = document.querySelector('.team2 .current-score');
    const addPointButtons = document.querySelectorAll('.add-point');
    const undoButton = document.getElementById('undo');
    const resetButton = document.getElementById('reset');
    const flagIcons = document.querySelectorAll('.flag-icon');
    const playerNames = document.querySelectorAll('.player-name');
    const toggleModeButton = document.getElementById('toggleMode');
    const changeFontButton = document.getElementById('changeFont');
    const changeFontSizeButton = document.getElementById('changeFontSize');
    const settingsButton = document.getElementById('settingsButton');
    const settingsMenu = document.getElementById('settingsMenu');

    const scores = ['0', '15', '30', '40', 'AD'];
    let currentScores = [0, 0];
    let sets = [[0, 0], [0, 0], [0, 0]];
    let currentSet = 0;
    let history = [];
    let isGameOver = false;
    let isTiebreak = false;

    const fonts = ['Roboto', 'Open Sans', 'Lato', 'Montserrat'];
    let currentFontIndex = 0;
    let currentFontSize = 16;

    function updateScore(team) {
        if (isGameOver) return;

        history.push({currentScores: [...currentScores], sets: JSON.parse(JSON.stringify(sets)), currentSet, isTiebreak});
        
        const otherTeam = team === 0 ? 1 : 0;
        
        if (isTiebreak) {
            currentScores[team]++;
            if (currentScores[team] >= 7 && currentScores[team] - currentScores[otherTeam] >= 2) {
                winTiebreak(team);
            }
        } else {
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
        }

        updateScoreboard();
    }

    function winGame(team) {
        sets[currentSet][team]++;
        if (sets[currentSet][0] === 6 && sets[currentSet][1] === 6) {
            isTiebreak = true;
            currentScores = [0, 0];
        } else if (sets[currentSet][team] >= 6 && sets[currentSet][team] - sets[currentSet][1 - team] >= 2) {
            winSet(team);
        } else {
            currentScores = [0, 0];
        }
        updateScoreboard();
    }

    function winTiebreak(team) {
        sets[currentSet][team] = 7;
        sets[currentSet][1 - team] = 6;
        winSet(team);
    }

    function winSet(team) {
        console.log(`El Equipo ${team + 1} ha ganado el set ${currentSet + 1}`);
        isTiebreak = false;
        currentScores = [0, 0];
        
        const setsWon = sets.filter(set => set[team] > set[1 - team]).length;
        
        if (setsWon === 2) {
            // Game over, team wins
            isGameOver = true;
            console.log(`¡El Equipo ${team + 1} gana el partido!`);
            alert(`¡El Equipo ${team + 1} gana el partido!`);
            disablePointButtons();
        } else {
            currentSet++;
        }
    }

    function updateScoreboard() {
        if (isTiebreak) {
            team1Score.textContent = currentScores[0].toString();
            team2Score.textContent = currentScores[1].toString();
        } else {
            team1Score.textContent = scores[currentScores[0]];
            team2Score.textContent = scores[currentScores[1]];
        }

        for (let i = 0; i < 3; i++) {
            document.querySelector(`.team1 .set${i + 1}`).textContent = sets[i][0];
            document.querySelector(`.team2 .set${i + 1}`).textContent = sets[i][1];
        }

        // Highlight cells if score is 40-40 (punto de oro), but not during tiebreak
        if (currentScores[0] === 3 && currentScores[1] === 3 && !isTiebreak) {
            team1Score.classList.add('golden');
            team2Score.classList.add('golden');
        } else {
            team1Score.classList.remove('golden');
            team2Score.classList.remove('golden');
        }
    }

    function undo() {
        if (isGameOver) return;

        if (history.length > 0) {
            const lastState = history.pop();
            currentScores = lastState.currentScores;
            sets = lastState.sets;
            currentSet = lastState.currentSet;
            isTiebreak = lastState.isTiebreak;
            updateScoreboard();
        }
    }

    function resetGame() {
        currentScores = [0, 0];
        sets = [[0, 0], [0, 0], [0, 0]];
        currentSet = 0;
        history = [];
        isGameOver = false;
        isTiebreak = false;
        updateScoreboard();
        enablePointButtons();
    }

    function disablePointButtons() {
        addPointButtons.forEach(button => button.disabled = true);
        undoButton.disabled = true;
    }

    function enablePointButtons() {
        addPointButtons.forEach(button => button.disabled = false);
        undoButton.disabled = false;
    }

    function toggleMode() {
        document.body.classList.toggle('dark-mode');
    }

    function changeFont() {
        currentFontIndex = (currentFontIndex + 1) % fonts.length;
        document.body.style.fontFamily = fonts[currentFontIndex];
    }

    function changeFontSize() {
        currentFontSize = currentFontSize === 16 ? 18 : 16;
        document.body.style.fontSize = `${currentFontSize}px`;
    }

    function toggleSettingsMenu() {
        settingsMenu.classList.toggle('active');
    }

    addPointButtons.forEach((button) => {
        button.addEventListener('click', () => {
            const team = parseInt(button.getAttribute('data-team')) - 1;
            updateScore(team);
        });
    });

    undoButton.addEventListener('click', undo);
    resetButton.addEventListener('click', resetGame);
    toggleModeButton.addEventListener('click', toggleMode);
    changeFontButton.addEventListener('click', changeFont);
    changeFontSizeButton.addEventListener('click', changeFontSize);
    settingsButton.addEventListener('click', toggleSettingsMenu);

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

    // Close settings menu when clicking outside
    document.addEventListener('click', (event) => {
        if (!settingsButton.contains(event.target) && !settingsMenu.contains(event.target)) {
            settingsMenu.classList.remove('active');
        }
    });

    updateScoreboard();
});