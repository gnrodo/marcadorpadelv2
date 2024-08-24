document.addEventListener('DOMContentLoaded', () => {
    const team1Score = document.querySelector('.team1 .score');
    const team2Score = document.querySelector('.team2 .score');
    const team1Sets = document.querySelector('.team1-sets');
    const team2Sets = document.querySelector('.team2-sets');
    const addPointButtons = document.querySelectorAll('.add-point');
    const resetButton = document.getElementById('reset');

    let scores = [0, 0];
    let sets = [0, 0];

    function updateScore(team) {
        scores[team]++;
        if (team === 0) {
            team1Score.textContent = scores[0];
        } else {
            team2Score.textContent = scores[1];
        }

        checkForSetWin();
    }

    function checkForSetWin() {
        if ((scores[0] >= 6 && scores[0] - scores[1] >= 2) || scores[0] === 7) {
            sets[0]++;
            team1Sets.textContent = sets[0];
            resetScores();
        } else if ((scores[1] >= 6 && scores[1] - scores[0] >= 2) || scores[1] === 7) {
            sets[1]++;
            team2Sets.textContent = sets[1];
            resetScores();
        }
    }

    function resetScores() {
        scores = [0, 0];
        team1Score.textContent = '0';
        team2Score.textContent = '0';
    }

    function resetGame() {
        scores = [0, 0];
        sets = [0, 0];
        team1Score.textContent = '0';
        team2Score.textContent = '0';
        team1Sets.textContent = '0';
        team2Sets.textContent = '0';
    }

    addPointButtons.forEach((button, index) => {
        button.addEventListener('click', () => updateScore(index));
    });

    resetButton.addEventListener('click', resetGame);
});