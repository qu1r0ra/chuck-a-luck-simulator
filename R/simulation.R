#' Simulate a single round or multiple rounds of Chuck-a-Luck
#'
#' @param n_rounds integer Number of rounds to simulate
#' @param bet_number integer The number bet on (1-6)
#' @param wager numeric The amount wagered per round
#' @param payouts numeric vector Named vector of payout multipliers
#' @return data.frame Contains Round, Die1-3, Matches, and NetWin
#' @export
simulate_chuck_a_luck <- function(n_rounds, bet_number, wager,
                                  payouts = DEFAULT_PAYOUT_MULTIPLIERS) {
  if (n_rounds <= 0) {
    data.frame()
  } else {
    dice1 <- sample(1:6, n_rounds, replace = TRUE)
    dice2 <- sample(1:6, n_rounds, replace = TRUE)
    dice3 <- sample(1:6, n_rounds, replace = TRUE)

    matches <- (
      (dice1 == bet_number) + (dice2 == bet_number) + (dice3 == bet_number)
    )

    net_win <- payouts[as.character(matches)] * wager

    data.frame(
      Round = 1:n_rounds,
      Die1 = dice1,
      Die2 = dice2,
      Die3 = dice3,
      Matches = matches,
      NetWin = net_win
    )
  }
}
