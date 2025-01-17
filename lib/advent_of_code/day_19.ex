defmodule AdventOfCode.Day19 do
  import Enum

  def parse_towels(towels) do
    towels |> String.split(", ", trim: true) |> map(fn s -> {byte_size(s), s} end)
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

  def boolint(true), do: 1
  def boolint(false), do: 0

  def part1(args) do
    {towels, targets} = args |> parse()

    reduce(targets, 0, fn target, acc -> acc + boolint(possible?(towels, target)) end)
  end

  def possibilities(towels, target) do
    if not possible?(towels, target) do
      0
    else
      reduce(towels, 0, fn {len, towel}, cpt ->
        if towel == target do
          cpt + 1
        else
          if binary_slice(target, -len, len) == towel do
            p = possibilities(towels, binary_slice(target, 0, byte_size(target) - len))
            cpt + p
          else
            cpt
          end
        end
      end)
    end
  end

  def count_possible(towels, target, memo) do
    case Map.fetch(memo, target) do
      {:ok, value} ->
        {value, memo}

      :error ->
        reduce(towels, {0, memo}, fn
          {len, towel}, {count, mem} ->
            if towel == target do
              {count + 1, Map.put(mem, target, 1)}
            else
              if binary_slice(target, -len, len) == towel do
                new_target = binary_slice(target, 0, byte_size(target) - len)

                if possible?(towels, new_target) do
                  {poss, new_mem} =
                    count_possible(towels, binary_slice(target, 0, byte_size(target) - len), mem)

                  {count + poss, Map.put(new_mem, new_target, poss)}
                else
                  {count, Map.put(mem, new_target, 0)}
                end
              else
                {count, mem}
              end
            end
        end)
    end
  end

  def part2(args) do
    {towels, targets} = args |> parse()

    reduce(targets, 0, fn target, cpt ->
      if possible?(towels, target) do
        {p, _} = count_possible(towels, target, %{})
        cpt + p
      else
        cpt
      end
    end)
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
