defmodule AdventOfCode.Day10 do
  import Enum

  def parse(args) do
    String.split(args, "\n", trim: true)
    |> with_index()
    |> map(fn {l, r} ->
      l |> to_charlist() |> with_index() |> map(fn {ch, col} -> {{r, col}, ch - ?0} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  # Utilities
  @dirs [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def move({r, c}, {dr, dc}), do: {r + dr, c + dc}

  def can_go_there?(grid, pos, d), do: Map.get(grid, move(pos, d), -1) == grid[pos] + 1

  ### Part 1
  def identify_trails(pos, grid) do
    identify_trails(pos, grid, MapSet.new()) |> MapSet.size()
  end

  def identify_trails(pos, grid, targets) do
    cond do
      grid[pos] == 9 and pos in targets ->
        targets

      grid[pos] == 9 ->
        MapSet.put(targets, pos)

      true ->
        reduce(@dirs, targets, fn d, l_targets ->
          if can_go_there?(grid, pos, d),
            do: identify_trails(move(pos, d), grid, l_targets),
            else: l_targets
        end)
    end
  end

  def part1(args) do
    grid = args |> parse()
    sum(for({k, v} <- grid, v == 0, do: identify_trails(k, grid)))
  end

  ### Part 2
  def count_trails(pos, grid) do
    if grid[pos] == 9,
      do: 1,
      else: sum(for d <- @dirs, can_go_there?(grid, pos, d), do: count_trails(move(pos, d), grid))
  end

  def part2(args) do
    grid = args |> parse()
    sum(for({k, v} <- grid, v == 0, do: count_trails(k, grid)))
  end
end
