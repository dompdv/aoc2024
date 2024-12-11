defmodule AdventOfCode.Day11 do
  import Enum

  def parse(args) do
    args |> String.trim() |> String.split(" ", trim: true) |> map(&String.to_integer/1)
  end

  def split_digits(e, n_digits) do
    cut_by = 10 ** div(n_digits, 2)
    {div(e, cut_by), rem(e, cut_by)}
  end

  def n_even(l) do
    reduce(l, 0, fn
      0, acc ->
        acc

      e, acc ->
        if rem(floor(:math.log10(e)) + 1, 2) == 0, do: acc + 1, else: acc
    end)
  end

  def mutate(e) do
    if e == 0 do
      1
    else
      n_digits = floor(:math.log10(e)) + 1
      if rem(n_digits, 2) == 0, do: split_digits(e, n_digits), else: e * 2024
    end
  end

  def blink(l), do: blink(l, [])
  def blink([], acc), do: acc

  def blink([e | l], acc) do
    case mutate(e) do
      {le, ri} -> blink(l, [ri, le | acc])
      v -> blink(l, [v | acc])
    end
  end

  def part1(args) do
    initial = args |> parse()
    reduce(1..25, initial, fn _, l -> blink(l) end) |> length()
  end

  def compute_seed(e, n) do
    reduce(1..n, [e], fn _i, l -> blink(l) end)
  end

  def part2(args) do
    initial = args |> parse()
    e = hd(initial)
    compute_seed(e, 75)

    #    memo =
    #      for e <- initial, into: %{} do
    #        result = compute_seed(e, 25)
    #        {e, {result, length(result)}}
    #      end
  end

  def test(_) do
    "0 1 10 99 999"
  end

  def test2(_), do: "125 17"
end
