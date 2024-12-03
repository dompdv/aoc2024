defmodule AdventOfCode.Day03 do
  import Enum

  def part1(args) do
    Regex.scan(~r/mul\((\d+),(\d+)\)/, args)
    |> map(fn [_a, b, c] -> String.to_integer(b) * String.to_integer(c) end)
    |> sum()
  end

  def part2(args) do
    Regex.scan(~r/mul\((\d+),(\d+)\)|do\(\)|don't\(\)/, args)
    |> map(fn
      [_, b, c] -> String.to_integer(b) * String.to_integer(c)
      ["do()"] -> :start
      _ -> :stop
    end)
    |> reduce({:running, 0}, fn
      :start, {_, acc} -> {:running, acc}
      :stop, {_, acc} -> {:stopped, acc}
      a, {:running, acc} -> {:running, acc + a}
      _, acc -> acc
    end)
    |> elem(1)
  end
end
