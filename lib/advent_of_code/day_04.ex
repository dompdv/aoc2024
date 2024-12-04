defmodule AdventOfCode.Day04 do
  import Enum

  @word ~c"XMAS"
  @dirs [{-1, 0}, {1, 0}, {-1, -1}, {1, 1}, {1, -1}, {-1, 1}, {0, -1}, {0, 1}]
  @sequences for {dr, dc} <- @dirs, do: for(i <- 0..3, do: {dr * i, dc * i})

  @seq2 [
    [{0, 0, ?A}, {-1, -1, ?M}, {1, 1, ?S}],
    [{0, 0, ?A}, {-1, -1, ?S}, {1, 1, ?M}],
    [{0, 0, ?A}, {1, -1, ?M}, {-1, 1, ?S}],
    [{0, 0, ?A}, {1, -1, ?S}, {-1, 1, ?M}]
  ]

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> with_index()
    |> map(fn {l, r} ->
      l |> to_charlist() |> with_index() |> map(fn {ch, col} -> {{r, col}, ch} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def puzzle_size(puzzle) do
    max(for {_, c} <- Map.keys(puzzle), do: c) + 1
  end

  def count_words(puzzle, {r, c}) do
    reduce(@sequences, 0, fn sequence, acc ->
      word = for {dr, dc} <- sequence, do: Map.get(puzzle, {r + dr, c + dc}, 0)
      if word == @word, do: acc + 1, else: acc
    end)
  end

  def part1(args) do
    puzzle = args |> parse()
    s = puzzle_size(puzzle)
    for(r <- 0..(s - 1), c <- 0..(s - 1), do: count_words(puzzle, {r, c})) |> sum()
  end

  def count_x(puzzle, {r, c}) do
    reduce(@seq2, 0, fn sequence, acc ->
      m = all?(for {dr, dc, letter} <- sequence, do: Map.get(puzzle, {r + dr, c + dc}) == letter)
      if m, do: acc + 1, else: acc
    end)
    |> then(fn matched ->
      if matched == 2, do: 1, else: 0
    end)
  end

  def part2(args) do
    puzzle = args |> parse()
    s = puzzle_size(puzzle)
    for(r <- 0..(s - 1), c <- 0..(s - 1), do: count_x(puzzle, {r, c})) |> sum()
  end
end
