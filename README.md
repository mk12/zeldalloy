# Zeldalloy

Zeldalloy is a collection of automated solutions to puzzles from games in [The Legend of Zelda][zelda] series. The problems are modelled in first-order logic, and solved by the [Alloy Analyzer][alloy]. Under the hood, Alloy uses a SAT solver to find a solution.

## Usage

First, you will need to [download Alloy][download]. On macOS, you can use `brew cask install alloy`. Then, open the puzzle's `.als` file in Alloy. From there, you can execute the `run` statement to solve the puzzle, and click Show to visualize the instance. Depending on the puzzle, you can:

- Click Theme > Load Theme... and choose the correspoding .thm file to get a better visualization.

- Copy the output from the Txt tab and paste it as standard input to the corresponding `.py` program.

## Puzzles

### Sacred Grove

This is the Guardian Statue Puzzle from Twilight Princess. You have to solve it in the Sacred Grove before getting the Master Sword.

All walkthroughs (example [one](https://www.zeldadungeon.net/Zelda11Guardian.php), [two](https://zeldauniverse.net/guides/twilight-princess/sidequests/guardian-statue-puzzle/)) take exactly 13 steps. As expected, Alloy produces no instance until we raise the scope to `for exactly 13 State`.

## License

© 2020 Mitchell Kember

Zeldalloy is available under the MIT License; see LICENSE for details.

[zelda]: https://en.wikipedia.org/wiki/The_Legend_of_Zelda
[alloy]: https://alloytools.org
[download]: https://alloytools.org/download.html
