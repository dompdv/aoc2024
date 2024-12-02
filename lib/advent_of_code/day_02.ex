defmodule AdventOfCode.Day02 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn s -> s |> String.split(" ", trim: true) |> map(&String.to_integer/1) end)
  end

  # Switch to increasing or decreasing
  def safe([a, b | _] = l) when a < b, do: safei(l)
  def safe(l), do: safed(l)

  # Increasing case
  def safei([_]), do: true
  def safei([a, b | r]) when a < b and b - a <= 3, do: safei([b | r])
  def safei(_), do: false

  # Decreasing case
  def safed([_]), do: true
  def safed([a, b | r]) when a > b and a - b <= 3, do: safed([b | r])
  def safed(_), do: false

  def part1(args) do
    args |> parse() |> map(&safe/1) |> filter(& &1) |> count()
  end

  def safe2(l) do
    # is initial sequence safe?
    # or check all sequences with one element removed
    safe(l) or
      for i <- 0..(length(l) - 1) do
        l |> List.delete_at(i) |> safe()
      end
      |> any?()
  end

  def part2(args) do
    args |> parse() |> map(&safe2/1) |> filter(& &1) |> count()
  end
end
