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

  def blink(%{}, acc), do: acc

  def blink([{e, occurences} | l], acc) do
    IO.inspect({e, occurences})

    case mutate(e) do
      {le, ri} ->
        new_acc =
          acc
          |> Map.update(le, occurences, &(&1 + occurences))
          |> Map.update(ri, 1, &(&1 + occurences))

        blink(l, new_acc)

      v ->
        new_acc = Map.update(acc, v, occurences, &(&1 + 1))
        blink(l, new_acc)
    end
  end

  def part1(args) do
    initial = args |> parse()
    initial_d = for e <- initial, into: %{}, do: {e, 1}
    reduce(1..25, initial_d, fn _, l -> blink(l) end) |> reduce(0, fn {_, v}, acc -> acc + v end)
  end

  def compute_seed(e, n) do
    reduce(1..n, [e], fn _i, l -> blink(l) end)
  end

  def part2(args) do
    initial = args |> parse()
    initial_d = for e <- initial, into: %{}, do: {e, 1}
    reduce(1..75, initial_d, fn _, l -> blink(l) end) |> reduce(0, fn {_, v}, acc -> acc + v end)
  end
end
