;; ==========================================
;; Strategy Scoring
;; ==========================================
;; Evaluates the score of a Strategy by testing it against an Opponent Strategy.

;; Converts a game outcome into a score for the player being tested
;; Win = 1.0, Draw = 0.0, Loss = -1.0
(= (score-result $result $player)
    (case $result
        (($player 1.0)
         (Draw 0.0)
         ((get-opponent $player) -1.0)
         ($_ (Error "Invalid game result")))))

;; Plays $n games against a specific opponent and tracks the results.
(= (evaluate-strategy-against $n $player-mark $player-policy $opponent-policy)
    (if (<= $n 0)
        Nil
        (let* (($result (eval (play-game $player-policy $opponent-policy)))
               ($current-score (score-result $result $player-mark)))
            (Cons $current-score (evaluate-strategy-against (- $n 1) $player-mark $player-policy $opponent-policy)))))

;; Backward-compatible single-opponent evaluation.
(= (evaluate-strategy $n $player-mark $player-policy $opponent-policy)
    (evaluate-strategy-against $n $player-mark $player-policy $opponent-policy))

;; Splits a game budget between random and minimax.
;; Pairs are distributed evenly; the odd leftover game goes to minimax.
(= (split-opponent-games $n)
    (let* (
        ($random-games (py-call (math.floor (/ $n 2))))
        ($minimax-games (- $n $random-games))
    )
    ($random-games $minimax-games)))

;; Default mixed-opponent evaluation used by strategy evolution.
(= (evaluate-strategy $n $player-mark $player-policy)
    (let* ((($random-games $minimax-games) (split-opponent-games $n))
           ($random-results (evaluate-strategy-against $random-games $player-mark $player-policy random-player))
           ($minimax-results (evaluate-strategy-against $minimax-games $player-mark $player-policy minimax-player)))
        (List.concat $random-results $minimax-results)))

;; Backward-compatible single-opponent scoring.
(= (score-strategy $n $player-policy $opponent-policy)
    (mkBScore (evaluate-strategy $n X $player-policy $opponent-policy)))

;; Default mixed-opponent scoring.
(= (score-strategy $n $player-policy)
    (mkBScore (evaluate-strategy $n X $player-policy)))