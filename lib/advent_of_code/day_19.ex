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

  # the trick is to start from the end of the osen
  def possible?(towels, target) do
    # try all possiible towels
    reduce_while(towels, 0, fn {len, towel}, _ ->
      cond do
        # if the target is a towel, we can stop
        towel == target ->
          {:halt, true}

        # if the target's end is the towel, we can try
        # We have found a solution if the rest of the osen (the target minus the towel) is possible
        binary_slice(target, -len, len) == towel ->
          if possible?(towels, binary_slice(target, 0, byte_size(target) - len)),
            do: {:halt, true},
            else: {:cont, false}

        # otherwise, we continue to another towel
        true ->
          {:cont, false}
      end
    end)
  end

  def part1(args) do
    {towels, targets} = args |> parse()

    for target <- targets do
      possible?(towels, target)
    end
    |> count(& &1)
  end

  # The trick is to memoize
  # memo is a dictionary of target -> count
  def count_possible(towels, target, memo) do
    case Map.fetch(memo, target) do
      {:ok, value} ->
        # It's a hit
        {value, memo}

      :error ->
        # it's a miss
        # Add all possible fitting towel
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

  def count_possible(towels, target), do: count_possible(towels, target, %{}) |> elem(0)

  def part2(args) do
    {towels, targets} = args |> parse()

    for target <- targets, possible?(towels, target) do
      count_possible(towels, target)
    end
    |> sum()
  end
end
