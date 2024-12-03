defmodule AdventOfCode.Day03 do
  import Enum

  def part1(args) do
    Regex.scan(~r/mul\((\d+),(\d+)\)/, args)
    |> reduce(0, fn [_a, b, c], acc -> acc + String.to_integer(b) * String.to_integer(c) end)
  end

  def part2(args) do
    Regex.scan(~r/mul\((\d+),(\d+)\)|do\(\)|don't\(\)/, args)
    |> reduce({:running, 0}, fn
      ["do()"], {_, acc} -> {:running, acc}
      [_, b, c], {:running, acc} -> {:running, acc + String.to_integer(b) * String.to_integer(c)}
      [_], {_, acc} -> {:stopped, acc}
      _, acc -> acc
    end)
    |> elem(1)
  end
end
