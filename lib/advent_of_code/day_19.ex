defmodule AdventOfCode.Day19 do
  import Enum

  def parse_towels(towels) do
    towels
    |> String.split(", ", trim: true)
    |> sort_by(fn t -> -String.length(t) end)
    |> map(fn s -> {String.length(s), s} end)
  end

  def parse_targets(targets), do: targets |> String.split("\n", trim: true)

  def parse(args) do
    args
    |> String.trim()
    |> String.split("\n\n", trim: true)
    |> then(fn [towels, targets] -> {parse_towels(towels), parse_targets(targets)} end)
  end

  def possible?(towels, target) do
    reduce_while(towels, 0, fn {len, towel}, _ ->
      if towel == target do
        {:halt, true}
      else
        if binary_slice(target, -len, len) == towel do
          if possible?(towels, binary_slice(target, 0, byte_size(target) - len)),
            do: {:halt, true},
            else: {:cont, false}
        else
          {:cont, false}
        end
      end
    end)
  end

  def possibilities(towels, target, memo) do
    if Map.has_key?(memo, target) do
      {memo[target], memo}
    else
      reduce(towels, {0, memo}, fn {len, towel}, {cpt, l_memo} = acc ->
        if towel == target do
          IO.inspect({towel}, label: "par ici")
          {cpt + 1, Map.put(l_memo, target, 1)}
        else
          if binary_slice(target, -len, len) == towel do
            {p, l_memo2} =
              possibilities(towels, binary_slice(target, 0, byte_size(target) - len), memo)

            {cpt + p, Map.put(l_memo2, target, p)}
          else
            acc
          end
        end
      end)
    end
  end

  def part1(args) do
    {towels, targets} = args |> parse()

    reduce(targets, 0, fn target, acc -> acc + if possible?(towels, target), do: 1, else: 0 end)
  end

  def part2(args) do
    {towels, targets} = args |> parse()
    memo = for {_, s} <- towels, into: %{}, do: {s, 1}

    reduce(targets, {0, memo}, fn target, {cpt, l_memo} = acc ->
      if possible?(towels, target) do
        IO.inspect(target)
        {inc_possib, new_memo} = possibilities(towels, target, l_memo)
        {cpt + inc_possib, new_memo}
      else
        acc
      end
    end)
    |> elem(0)
  end

  def test(_) do
    """
    r, wr, b, g, bwu, rb, gb, br

    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
    """
  end
end
