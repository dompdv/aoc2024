defmodule AdventOfCode.Day22 do
  import Enum
  def parse(args), do: args |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)

  def next(s) do
    s = (s * 64) |> Bitwise.bxor(s) |> rem(16_777_216)
    s = floor(s / 32) |> Bitwise.bxor(s) |> rem(16_777_216)
    (s * 2048) |> Bitwise.bxor(s) |> rem(16_777_216)
  end

  def iterate(s, n) do
    reduce(1..n, s, fn _, acc -> next(acc) end)
  end

  def part1(args) do
    args |> parse() |> map(&iterate(&1, 2000)) |> sum()
  end

  def part2(args) do
    args |> test() |> parse()
  end

  def test(_) do
    """
    1
    10
    100
    2024
    """
  end
end
