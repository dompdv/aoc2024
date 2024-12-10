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

  @dirs [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def move({r, c}, {dr, dc}), do: {r + dr, c + dc}

  def count_trails(pos, grid, targets) do
    current_height = grid[pos]

    cond do
      current_height == 9 and pos in targets ->
        targets

      current_height == 9 ->
        MapSet.put(targets, pos)

      true ->
        reduce(@dirs, targets, fn d, l_targets ->
          if Map.get(grid, move(pos, d), -1) == current_height + 1 do
            count_trails(move(pos, d), grid, l_targets)
          else
            l_targets
          end
        end)
    end
  end

  def part1(args) do
    grid = args |> parse()

    for {k, v} <- grid, v == 0 do
      count_trails(k, grid, MapSet.new()) |> MapSet.size()
    end
    |> sum()
  end

  def part2(args) do
    args
  end

  def test(_) do
    """
    0123
    1234
    8765
    9876
    """
  end

  def test1(_) do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """
  end
end
