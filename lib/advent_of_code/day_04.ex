defmodule AdventOfCode.Day04 do
  import Enum

  @word Enum.with_index(~c"XMAS")
  @dirs for dr <- -1..1, dc <- -1..1, {dr, dc} != {0, 0}, do: {dr, dc}
  @sequences_1 for {dr, dc} <- @dirs, do: for({letter, i} <- @word, do: {dr * i, dc * i, letter})

  @sequences_2 [
    [{0, 0, ?A}, {-1, -1, ?M}, {1, 1, ?S}],
    [{0, 0, ?A}, {-1, -1, ?S}, {1, 1, ?M}],
    [{0, 0, ?A}, {1, -1, ?M}, {-1, 1, ?S}],
    [{0, 0, ?A}, {1, -1, ?S}, {-1, 1, ?M}]
  ]

  def parse(args) do
    splitted = String.split(args, "\n", trim: true)

    puzzle =
      splitted
      |> with_index()
      |> map(fn {l, r} ->
        l |> to_charlist() |> with_index() |> map(fn {ch, col} -> {{r, col}, ch} end)
      end)
      |> List.flatten()
      |> Map.new()

    {puzzle, length(splitted)}
  end

  def count_matching({r, c}, puzzle, sequences) do
    reduce(sequences, 0, fn sequence, acc ->
      m = all?(for {dr, dc, letter} <- sequence, do: Map.get(puzzle, {r + dr, c + dc}) == letter)
      if m, do: acc + 1, else: acc
    end)
  end

  def part1(args) do
    {puzzle, s} = args |> parse()

    for(r <- 0..(s - 1), c <- 0..(s - 1), do: count_matching({r, c}, puzzle, @sequences_1))
    |> sum()
  end

  def part2(args) do
    {puzzle, s} = args |> parse()

    for(r <- 0..(s - 1), c <- 0..(s - 1), do: count_matching({r, c}, puzzle, @sequences_2))
    |> reduce(0, fn
      2, acc -> acc + 1
      _, acc -> acc
    end)
  end
end
