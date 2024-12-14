defmodule AdventOfCode.Day13 do
  import Enum

  def parse_machine(machine) do
    [a, b, p] = String.split(machine, "\n", trim: true)

    [[_, ax, ay]] = Regex.scan(~r/Button A: X\+(\d+), Y\+(\d+)/, a)
    [[_, bx, by]] = Regex.scan(~r/Button B: X\+(\d+), Y\+(\d+)/, b)
    [[_, tx, ty]] = Regex.scan(~r/Prize: X=(\d+), Y=(\d+)/, p)

    {{String.to_integer(ax), String.to_integer(ay)},
     {String.to_integer(bx), String.to_integer(by)},
     {String.to_integer(tx), String.to_integer(ty)}}
  end

  def parse(args), do: args |> String.split("\n\n", trim: true) |> map(&parse_machine/1)

  def is_an_integer(x) when is_integer(x), do: true
  def is_an_integer(x), do: x == round(x)

  def play1(p), do: play(p, true)
  def play2(p), do: play(p, false)

  def play({{ax, ay}, {bx, by}, {tx, ty}}, max_100) do
    det = ax * by - ay * bx

    if det == 0 do
      0
    else
      a = (tx * by - ty * bx) / det
      b = (ax * ty - ay * tx) / det

      if is_an_integer(a) and is_an_integer(b) and a >= 0 and b >= 0 and
           (not max_100 or (max_100 and a <= 100 and b < 100)) do
        round(3 * a + b)
      else
        0
      end
    end
  end

  def magnify(l, f), do: map(l, fn {a, b, {tx, ty}} -> {a, b, {f + tx, f + ty}} end)

  def part1(args), do: args |> parse() |> map(&play1/1) |> sum()
  def part2(args), do: args |> parse() |> magnify(10_000_000_000_000) |> map(&play2/1) |> sum()
end
