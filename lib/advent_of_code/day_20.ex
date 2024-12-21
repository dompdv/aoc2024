defmodule AdventOfCode.Day20 do
  import Enum
  @dirs [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
  @big_number 1_000_000_000

  ### Standard grid parsing
  def parse(grid) do
    grid
    |> String.trim()
    |> String.split("\n", trim: true)
    |> with_index()
    |> flat_map(fn {row, r} ->
      row
      |> to_charlist()
      |> with_index()
      |> map(fn {cell, c} -> {{r, c}, cell} end)
    end)
    |> reduce({MapSet.new(), nil, nil, %{}}, fn e, {grid, start, finish, gridr} ->
      case e do
        {pos, ?#} -> {grid, start, finish, Map.put(gridr, pos, "#")}
        {pos, ?.} -> {MapSet.put(grid, pos), start, finish, Map.put(gridr, pos, ".")}
        {pos, ?S} -> {MapSet.put(grid, pos), pos, finish, Map.put(gridr, pos, ".")}
        {pos, ?E} -> {MapSet.put(grid, pos), start, pos, Map.put(gridr, pos, ".")}
      end
    end)

    # {a list of empty cells, start, finish, a map representing empty and wall cells}
  end

  def solve({road, start, finish, grid}) do
    heap = MapSet.new([start])
    visited = MapSet.new()
    distances = for(pos <- Map.keys(grid), into: %{}, do: {pos, @big_number}) |> Map.put(start, 0)
    paths = for(pos <- Map.keys(grid), into: %{}, do: {pos, []})
    dijkstra(heap, visited, distances, paths, road, finish)
  end

  def possible_moves({r, c}, visited, road) do
    reduce(@dirs, [], fn {dr, dc}, acc ->
      landing = {r + dr, c + dc}

      if landing in visited or landing not in road,
        do: acc,
        else: [landing | acc]
    end)
  end

  def dijkstra(heap, visited, distances, paths, road, finish) do
    if MapSet.size(heap) == 0 do
      {distances[finish], paths[finish]}
    else
      p_min = min_by(heap, fn pos -> distances[pos] end)
      dist_min = distances[p_min]
      new_visited = MapSet.put(visited, p_min)

      {new_heap, new_distances, new_paths} =
        reduce(
          possible_moves(p_min, new_visited, road),
          {MapSet.delete(heap, p_min), distances, paths},
          fn landing, {l_heap, l_dist, l_path} = acc ->
            dist = dist_min + 1

            if dist >= l_dist[landing] do
              acc
            else
              {MapSet.put(l_heap, landing), Map.put(l_dist, landing, dist),
               Map.put(l_path, landing, [p_min | l_path[p_min]])}
            end
          end
        )

      dijkstra(new_heap, new_visited, new_distances, new_paths, road, finish)
    end
  end

  def move({r, c}, {dr, dc}) do
    {r + dr, c + dc}
  end

  def generate_couples(grid, road) do
    for {sp, _} <- grid, d <- @dirs do
      ep = move(sp, d)
      if sp not in road and ep in road, do: {sp, ep}, else: nil
    end
    |> Enum.reject(&is_nil/1)
  end

  def in_path(path, sp, ep) do
    if sp in path and ep in path, do: two_in_path(path, sp, ep), else: false
  end

  def two_in_path([], _sp, _ep), do: false
  def two_in_path([_], _sp, _ep), do: false

  def two_in_path([sp, ep | _r], sp, ep), do: true
  def two_in_path([_, b | r], sp, ep), do: two_in_path([b | r], sp, ep)

  def part1(args) do
    {road, start, finish, grid} = args |> parse()

    {base, _} = solve({road, start, finish, grid})
    couples = generate_couples(grid, road)

    IO.inspect(length(couples))

    Task.async_stream(couples, fn {sp, ep} ->
      new_road = road |> MapSet.put(sp)

      {len, path} = solve({new_road, start, finish, grid})
      if in_path(path, sp, ep), do: base - len, else: nil
    end)
    |> Stream.map(&elem(&1, 1))
    |> frequencies()
    |> filter(fn {gain, _} -> gain != nil and gain >= 100 end)
    |> map(&elem(&1, 1))
    |> sum()
  end

  def build_paths(c_pos, path, steps, blocks, road) do
    if steps == 3 do
      if c_pos in blocks, do: [], else: [reverse([c_pos | path])]
    else
      reduce(@dirs, [], fn d, paths ->
        n_pos = move(c_pos, d)

        cond do
          n_pos not in road and n_pos not in blocks -> paths
          n_pos in path -> paths
          n_pos not in blocks -> [reverse([n_pos | path]) | paths]
          true -> build_paths(n_pos, [n_pos | path], steps + 1, blocks, road) ++ paths
        end
      end)
    end
  end

  def generate_couples2(grid, road) do
    blocks = for({sp, _} <- grid, sp not in road, do: sp) |> MapSet.new()

    reduce(blocks, [], fn sp, acc ->
      build_paths(sp, [sp], 1, blocks, road) ++ acc
    end)
  end

  def is_sublist(sublist, list) do
    sublist_length = length(sublist)

    list
    |> Enum.chunk_every(sublist_length, 1, :discard)
    |> Enum.any?(fn chunk -> chunk == sublist end)
  end

  def part2(args) do
    {road, start, finish, grid} = args |> test() |> parse()

    {base, _} = solve({road, start, finish, grid})
    couples = generate_couples2(grid, road)
    IO.inspect(couples)
    IO.inspect(length(couples))
    #    raise "opo"

    Task.async_stream(couples, fn cheat_path ->
      new_road = MapSet.union(road, MapSet.new(cheat_path))

      {len, path} = solve({new_road, start, finish, grid})
      if is_sublist(cheat_path, path), do: base - len, else: nil
    end)
    |> Stream.map(&elem(&1, 1))
    |> frequencies()
    |> filter(fn {gain, _} -> gain != nil and gain >= 50 end)
    |> map(&elem(&1, 1))
    |> sum()
  end

  def test(_) do
    """
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############
    """
  end
end
