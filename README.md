# Zeldalloy

Zeldalloy is a collection of automated solutions to puzzles from games in [The Legend of Zelda][zelda] series.

The problems are modelled in first-order logic, solved by the [Alloy Analyzer][alloy], and visualized by Python scripts. Each puzzle also includes timing information and a comparison to popular walkthroughs.

## Getting started

First, [Download Alloy][download]. On macOS, you can use `brew cask install alloy`.

Then, open the `model.als` file for one of the [puzzles](#puzzles), and click **Execute** to find a solution. (For puzzles with multiple variants, pick one using **Execute > Run ...** in the menu bar.) When it finishes, click **Show** to visualize the instance. From here you have two options:

1. Look at the solution in Alloy's **Viz** representation. For some puzzles there is a `theme.thm` file you can load with **Theme > Load Theme...** in the menu bar. Among other customizations, these project over `State`, so you can navigate between states using the arrows at the bottom of the window.

2. Switch to the **Txt** tab, copy the output, and save it to a file `my-instance.txt`. Then run `./show my-instance.txt` in the puzzle directory to print all the states. Add the `-i` flag to instead step through states by pressing the <kbd>Enter</kbd> key.

The second approach is usually much better, since it prints the two-dimensional layout of the puzzle. This repository includes `instance.txt` solutions for each puzzle, so you can run `show.py` without using Alloy.

## Puzzles

### Phantom Hourglass

- [Mutoh's Temple Xs and Os tiles](mutoh-tiles)

### Oracle of Ages

- [Crown Dungeon synchronized statues](crown-statues)

### Twilight Princess

- [Sacred Grove guardian statues](sacred-grove)
- [Snowpeak Ruins sliding blocks](snowpeak-blocks)

## Organization

The puzzles are organized like this:

```
puzzle-name/
    README.md        -- puzzle description
    model.als        -- Alloy model of the puzzle
    show.py          -- script for visualizing instances
    instance-##.txt  -- solution instance in Alloy txt format
    screenshot.jpg   -- in-game screenshot of the puzzle
```

## Zelda notes

- All Twilight Princess puzzles use the GameCube (or HD normal mode) orientation, not the Wii (or HD hero mode) mirrored orientation.

## Alloy notes

- We find the optimal solution by increasing the `State` scope by 1 until Alloy finds an instance. (Going down until it fails to find is incorrect unless the puzzle allows a no-op move.)

- When a solution takes _N_ steps, it requires _N_+1 states. This is important to keep in mind when comparing our results to walkthroughs, which typically list the _N_ transitions.

- The expression `1 + 2` means the set containing 1 and 2, not the integer 3. To add numbers, you have to use the built-in function `plus`. For example, `1.plus[2] = 3` is true.

- Scopes on `Int` work differently from other sets. The scope `for 4 Int` means using 4-bit signed integers, so from -8 to +7, which gives 16 possible values in total.

- Puzzles whose coordinates fit in _N_ bits often need an `Int` scope of _N_+1 because the result of adding or subtracting can overflow _N_ bits.

## Contributing

Here are a few things for contributors to keep in mind:

- Run `make dev` to install dev dependencies ([black][], [mypy][], and [pylint][]).
- Run `make fmt` to format all Python code.
- Run `make tc` to typecheck top-level Python code.
- Run `make lint` to lint top-level Python code.

## License

© 2020 Mitchell Kember

Zeldalloy is available under the MIT License; see LICENSE for details.

[zelda]: https://en.wikipedia.org/wiki/The_Legend_of_Zelda
[alloy]: https://alloytools.org
[download]: https://alloytools.org/download.html
[black]: https://github.com/psf/black
[mypy]: http://mypy-lang.org
[pylint]: http://mypy-lang.org
