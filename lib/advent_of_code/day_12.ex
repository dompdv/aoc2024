defmodule AdventOfCode.Day12 do
  import Enum

  def parse(args) do
    String.split(args, "\n", trim: true)
    |> with_index()
    |> map(fn {l, r} ->
      l |> to_charlist() |> with_index() |> map(fn {ch, col} -> {{r, col}, ch} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def explode(grid), do: explode(Map.to_list(grid), MapSet.new(), nil, [], grid)

  def explode(to_visit, visited, plant_type, regions, grid)

  def explode([], _, _, regions, _), do: regions

  def explode([{pos, pt} | rest], visited, nil, regions, grid) do
    if pos in visited do
      explode(rest, visited, nil, regions, grid)
    else
      {new_region, new_visited} = grow_region(pos, pt, MapSet.put(visited, pos), [pos], grid)
      explode(rest, new_visited, nil, [new_region | regions], grid)
    end
  end

  @dirs [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
  def move({r, c}, {dr, dc}), do: {r + dr, c + dc}

  def grow_region(pos, pt, visited, region, grid) do
    reduce(@dirs, {region, visited}, fn d, {r, v} ->
      new_pos = move(pos, d)

      if new_pos in v do
        {r, v}
      else
        case Map.get(grid, new_pos) do
          nil ->
            {r, v}

          new_pt when new_pt == pt ->
            grow_region(new_pos, pt, MapSet.put(v, new_pos), [new_pos | r], grid)

          _ ->
            {r, v}
        end
      end
    end)
  end

  def perimeter1(region) do
    for r <- region, delta <- @dirs do
      if move(r, delta) not in region, do: 1, else: 0
    end
    |> sum()
  end

  @dirs_dir [{{-1, 0}, :h}, {{1, 0}, :b}, {{0, -1}, :l}, {{0, 1}, :r}]

  def fences(region) do
    for r <- region, {delta, orientation} <- @dirs_dir do
      new_pos = move(r, delta)
      IO.inspect({r, delta, orientation, new_pos})
      if new_pos not in region, do: {new_pos, orientation}, else: nil
    end
    |> reject(&(&1 == nil))
  end

  def perimeter2(region) do
    region
    |> fences()
    |> group_by(fn {{r, c}, orientation} ->
      case orientation do
        :l -> {c, :l}
        :r -> {c, :r}
        :h -> {r, :h}
        :b -> {r, :b}
      end
    end)
    |> map(fn
      {{_, :l}, l} -> for {{r, _}, _} <- l, do: r
      {{_, :r}, l} -> for {{r, _}, _} <- l, do: r
      {{_, :h}, l} -> for {{_, c}, _} <- l, do: c
      {{_, :b}, l} -> for {{_, c}, _} <- l, do: c
    end)
    |> map(&split_contiguous/1)
    |> List.flatten()
    |> sum()
    |> dbg()
  end

  def split_contiguous(l) do
    reduce(sort(l), {nil, 0}, fn e, {prev, cpt} ->
      cond do
        prev == nil -> {e, cpt + 1}
        e == prev + 1 -> {e, cpt}
        true -> {e, cpt + 1}
      end
    end)
    |> elem(1)
  end

  def area(region), do: length(region)
  def price1(region), do: area(region) * perimeter1(region)
  #
  def price2(region), do: perimeter2(region) * area(region)

  def part1(args), do: args |> parse() |> explode() |> map(&price1/1) |> sum()

  def part2(args) do
    args |> parse() |> explode() |> map(&price2/1) |> sum()
  end

  def test(_) do
    """
    AAAA
    BBCD
    BBCC
    EEEC
    """
  end

  def test2(_) do
    """
    EEEEE
    EXXXX
    EEEEE
    EXXXX
    EEEEE
    """
  end
end
