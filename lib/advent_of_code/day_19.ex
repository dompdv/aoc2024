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
  # memo is a map of %{target => count}
  def count_possible(towels, target, memo) do
    case Map.fetch(memo, target) do
      {:ok, value} ->
        # It's a hit
        {value, memo}

      :error ->
        # it's a miss
        # Add all count for possible fitting towels
        reduce(
          # Loop on all towels
          towels,
          # {total possibilities, current memoization map}
          {0, memo},
          fn {len, towel}, {count, mem} ->
            cond do
              towel == target ->
                # the target is the towel, we have 1 possibility. Let'sd memorize this
                {count + 1, Map.put(mem, target, 1)}

              binary_slice(target, -len, len) == towel ->
                # the target ends with the towel
                new_target = binary_slice(target, 0, byte_size(target) - len)

                if possible?(towels, new_target) do
                  {poss, new_mem} =
                    count_possible(towels, binary_slice(target, 0, byte_size(target) - len), mem)

                  # memorize the possibilities count
                  {count + poss, Map.put(new_mem, new_target, poss)}
                else
                  # No possiblity, so count == 0, memorize this
                  {count, Map.put(mem, new_target, 0)}
                end

              true ->
                # continue to the next towel
                {count, mem}
            end
          end
        )
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
