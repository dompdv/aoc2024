defmodule AdventOfCode.Day07 do
  import Enum

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def parse_line(line) do
    [target, rest] = String.split(line, ": ")
    numbers = String.split(rest, " ", trim: true) |> map(&String.to_integer/1)
    {String.to_integer(target), numbers}
  end

  def represents_in_base(n, base), do: reverse(digits(n, base))
  def digits(n, base) when n < base, do: [n]
  def digits(n, base), do: [rem(n, base) | digits(div(n, base), base)]
  def pad_with_0s(list, pad), do: List.duplicate(0, pad - length(list)) ++ list

  def works?({target, numbers}, operator_types) do
    n_operators = length(numbers) - 1
    n_possibilities = operator_types ** n_operators

    reduce_while(0..(n_possibilities - 1), false, fn i, _ ->
      operators = represents_in_base(i, operator_types) |> pad_with_0s(n_operators)
      compute = evaluate(numbers, operators)
      if compute == target, do: {:halt, target}, else: {:cont, false}
    end)
  end

  def evaluate([a], []), do: a

  def evaluate([a, b | r], [op | ops]) do
    case op do
      0 ->
        evaluate([a + b | r], ops)

      1 ->
        evaluate([a * b | r], ops)

      2 ->
        concat = (Integer.to_string(a) <> Integer.to_string(b)) |> String.to_integer()
        evaluate([concat | r], ops)
    end
  end

  def check(args, n_ops) do
    args |> parse() |> map(fn line -> works?(line, n_ops) end) |> filter(&(&1 != false)) |> sum()
  end

  def part1(args), do: check(args, 2)
  def part2(args), do: check(args, 3)
end
