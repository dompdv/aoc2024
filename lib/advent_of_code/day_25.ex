defmodule AdventOfCode.Day25 do
  import Enum

  def parse(args),
    do:
      args
      |> String.split("\n\n", trim: true)
      |> map(&parse_lock_key/1)
      |> group_by(&elem(&1, 0))

  def parse_lock_key("#" <> _ = lock), do: parse_lock_key(:lock, lock)
  def parse_lock_key(key), do: parse_lock_key(:key, key)

  def parse_lock_key(type, rows) do
    {type,
     rows
     |> String.replace("\n", "")
     |> to_charlist()
     |> with_index()
     |> reduce(%{}, fn
       {?#, i}, acc -> Map.update(acc, rem(i, 5), 0, &(&1 + 1))
       {_, _}, acc -> acc
     end)}
  end

  def match_kl?(lock, key) do
    for(i <- 0..4, do: Map.get(lock, i) + Map.get(key, i)) |> all?(&(&1 < 6))
  end

  def part1(args) do
    %{lock: locks, key: keys} = args |> parse()

    for {_, lock} <- locks, {_, key} <- keys do
      if match_kl?(lock, key), do: 1, else: 0
    end
    |> sum()
  end

  def part2(args) do
    args
  end

  def test(_) do
    """
    #####
    .####
    .####
    .####
    .#.#.
    .#...
    .....

    #####
    ##.##
    .#.##
    ...##
    ...#.
    ...#.
    .....

    .....
    #....
    #....
    #...#
    #.#.#
    #.###
    #####

    .....
    .....
    #.#..
    ###..
    ###.#
    ###.#
    #####

    .....
    .....
    .....
    #....
    #.#..
    #.#.#
    #####
    """
  end
end
