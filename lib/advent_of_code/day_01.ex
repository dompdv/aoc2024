defmodule AdventOfCode.Day01 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn s ->
      s |> String.split(" ", trim: true) |> map(&String.to_integer/1) |> List.to_tuple()
    end)
    |> unzip()
  end

  def part1(args) do
    {l1, l2} = parse(args)
    zip(sort(l1), sort(l2)) |> map(fn {a, b} -> abs(a - b) end) |> sum()
  end

  def part2(args) do
    {l1, l2} = parse(args)
    freq = frequencies(l2)
    for(n <- l1, do: n * Map.get(freq, n, 0)) |> sum()
  end
end
