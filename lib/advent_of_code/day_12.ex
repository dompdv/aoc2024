defmodule AdventOfCode.Day12 do
  import Enum

  # Grid parsing
  def parse(args) do
    String.split(args, "\n", trim: true)
    |> with_index()
    |> map(fn {l, r} ->
      l |> to_charlist() |> with_index() |> map(fn {ch, col} -> {{r, col}, ch} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  # Direction and type of fence
  @dirs_dir [{{-1, 0}, :h}, {{1, 0}, :b}, {{0, -1}, :l}, {{0, 1}, :r}]

  def move({r, c}, {dr, dc}), do: {r + dr, c + dc}

  # Split the grid in regions of the same plant type
  def grid_into_regions(grid),
    do: grid_into_regions(Map.to_list(grid), MapSet.new(), [], grid)

  def grid_into_regions(to_visit, visited, regions, grid)

  def grid_into_regions([], _, regions, _), do: regions

  def grid_into_regions([{pos, pt} | rest], visited, regions, grid) do
    # go through each cell on the grid. Jump over visited cells
    if pos in visited do
      grid_into_regions(rest, visited, regions, grid)
    else
      # If it's not visited yet, start a region. The visited set is updated with the new region
      {new_region, new_visited} = grow_region(pos, pt, MapSet.put(visited, pos), [pos], grid)
      grid_into_regions(rest, new_visited, [new_region | regions], grid)
    end
  end

  # From a starting point, identifies the region of the same plant type
  # pos = position, pt = plan type of the region, visited = set of visited cells, region = list of cells in the region, grid = the grid
  def grow_region(pos, pt, visited, region, grid) do
    # try to move in all 4 directions
    @dirs_dir
    |> reduce({region, visited}, fn {d, _}, {r, v} = acc ->
      new_pos = move(pos, d)
      new_pos_plant = Map.get(grid, new_pos)

      cond do
        # already visited, skip
        new_pos in v ->
          acc

        # Plant of the same type, add to the region and continue growing the region
        new_pos_plant == pt ->
          grow_region(new_pos, pt, MapSet.put(v, new_pos), [new_pos | r], grid)

        # Plant of a different type or outside the grid, skip
        true ->
          acc
      end
    end)
  end

  ### Part 1

  # Part 1 perimeter
  def perimeter1(region) do
    # For each cell, the perimeter is the number of cells around it that are not in the region
    sum(
      for r <- region, {delta, _} <- @dirs_dir do
        if move(r, delta) not in region, do: 1, else: 0
      end
    )
  end

  ### Part 2

  # Compute the fences around the region
  # A fence is a tuple {pos, fence_type} where pos is the position of the fence and fence_type is (h, b, l, r)
  # A "l" fence is on the left of the cell, a "r" fence is on the right, a "h" fence is above and a "b" fence is below
  def fences(region) do
    for r <- region, {delta, orientation} <- @dirs_dir do
      new_pos = move(r, delta)
      if new_pos not in region, do: {new_pos, orientation}, else: nil
    end
    |> reject(&(&1 == nil))
  end

  # Given a list of element, split it in segments and count them.
  # A segment is a list of elements that are separated by 1 unit
  # For example, [1, 2, 3, 5, 6, 7, 9] will be split in [[1, 2, 3], [5, 6, 7], [9]] and will give 3 segments
  def count_segments(l) do
    reduce(sort(l), {nil, 0}, fn e, {prev, cpt} ->
      if prev == nil or e != prev + 1, do: {e, cpt + 1}, else: {e, cpt}
    end)
    |> elem(1)
  end

  def extract_rows(l), do: for({{r, _}, _} <- l, do: r)
  def extract_cols(l), do: for({{_, c}, _} <- l, do: c)

  # Part 2 perimeter
  def perimeter2(region) do
    region
    # Compute the fences
    |> fences()
    # Group the fences: we group by the type of the fence, provided that they share the same row or column (depending on the fence type)
    |> group_by(fn {{r, c}, fence_type} ->
      if fence_type in [:l, :r], do: {c, fence_type}, else: {r, fence_type}
    end)
    # For each group, we extract the rows or columns list (depending on the orientation)
    # This list will represent, for example, the rows of all the fences that are vertically aligned (same column and same type)
    # We then count the segments
    |> map(fn {{_, fence_type}, l} ->
      if(fence_type in [:l, :r], do: extract_rows(l), else: extract_cols(l)) |> count_segments()
    end)
    |> sum()
  end

  def run(args, perimeter_fun) do
    args
    |> parse()
    |> grid_into_regions()
    |> map(fn region -> length(region) * perimeter_fun.(region) end)
    |> sum()
  end

  def part1(args), do: run(args, &perimeter1/1)
  def part2(args), do: run(args, &perimeter2/1)
end
