defmodule AdventOfCode.Day11 do
  import Enum

  def parse(args) do
    args
    |> String.trim()
    |> String.split(" ", trim: true)
    |> map(&String.to_integer/1)
    |> frequencies()
  end

  def split_digits(e, n_digits) do
    cut_by = 10 ** div(n_digits, 2)
    {div(e, cut_by), rem(e, cut_by)}
  end

  def mutate(e) do
    if e == 0 do
      1
    else
      n_digits = floor(:math.log10(e)) + 1
      if rem(n_digits, 2) == 0, do: split_digits(e, n_digits), else: e * 2024
    end
  end

  def blink(l) do
    reduce(l, %{}, fn {e, occurences}, acc ->
      case mutate(e) do
        {le, ri} ->
          acc
          |> Map.update(le, occurences, &(&1 + occurences))
          |> Map.update(ri, occurences, &(&1 + occurences))

        v ->
          Map.update(acc, v, occurences, &(&1 + occurences))
      end
    end)
  end

  def blink_many(stones, n_blinks) do
    reduce(1..n_blinks, stones, fn _, l -> blink(l) end)
    |> reduce(0, fn {_, v}, acc -> acc + v end)
  end

  def part1(args), do: args |> parse() |> blink_many(25)

  def part2(args), do: args |> parse() |> blink_many(75)
end
