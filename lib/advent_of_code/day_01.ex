defmodule AdventOfCode.Day01 do
  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn s ->
      [a, b] = String.split(s, " ", trim: true)
      {String.to_integer(a), String.to_integer(b)}
    end)
    |> Enum.unzip()
  end

  def part1(args) do
    {l1, l2} = parse(args)
    Enum.zip(Enum.sort(l1), Enum.sort(l2)) |> Enum.map(fn {a, b} -> abs(a - b) end) |> Enum.sum()
  end

  def part2(args) do
    {l1, l2} = parse(args)
    freq = Enum.frequencies(l2)
    for(n <- l1, do: n * Map.get(freq, n, 0)) |> Enum.sum()
  end
end
