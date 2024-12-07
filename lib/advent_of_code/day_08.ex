defmodule AdventOfCode.Day08 do
  import Enum

  def parse(args) do
    args |> String.split("\n", trim: true)
  end

  def part1(args) do
    args |> test() |> parse()
  end

  def part2(args) do
    args |> test() |> parse()
  end

  def test(_) do
    """
    line 1
    """
  end
end
