defmodule AdventOfCode.Day16 do
  import Enum

  @dirs %{n: {-1, 0}, e: {0, 1}, s: {1, 0}, w: {0, -1}}
  @big_number 1_000_000_000
  @clockwise %{n: :e, e: :s, s: :w, w: :n}
  @counter_clockwise %{n: :w, w: :s, s: :e, e: :n}

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
  end

  def move({r, c}, dir) do
    {dr, dc} = @dirs[dir]
    {r + dr, c + dc}
  end

  def cw(dir), do: @clockwise[dir]
  def ccw(dir), do: @counter_clockwise[dir]

  def possible_moves({cell, facing}, visited, grid) do
    reduce(
      [{:forward, facing}, {:cw, cw(facing)}, {:ccw, ccw(facing)}],
      [],
      fn {move_type, dir}, acc ->
        {landing, _} = landing_pos = {move(cell, dir), dir}

        if landing_pos in visited or landing not in grid,
          do: acc,
          else: [{move_type, {landing, dir}} | acc]
      end
    )
  end

  def solve({grid, start, finish, _}) do
    distances =
      for(cell <- grid, dir <- [:n, :e, :s, :w], into: %{}, do: {{cell, dir}, @big_number})
      |> Map.put({start, :e}, 0)

    visited = MapSet.new()
    heap = MapSet.new([{start, :e}])

    paths = for(cell <- grid, dir <- [:n, :e, :s, :w], into: %{}, do: {{cell, dir}, []})

    dijkstra(heap, visited, distances, paths, grid, finish)
  end

  def dijkstra(heap, visited, distances, paths, grid, finish) do
    if MapSet.size(heap) == 0 do
      for dir <- [:n, :e, :s, :w], do: {distances[{finish, dir}], reverse(paths[{finish, dir}])}
    else
      p_min = min_by(heap, fn pos -> distances[pos] end)
      dist_min = distances[p_min]
      new_visited = MapSet.put(visited, p_min)

      p_moves = possible_moves(p_min, new_visited, grid)

      {new_heap, new_distance, new_paths} =
        reduce(
          p_moves,
          {MapSet.delete(heap, p_min), distances, paths},
          fn {move_type, landing_pos}, {l_heap, l_dist, l_paths} = acc ->
            dist = dist_min + if move_type == :forward, do: 1, else: 1001

            if dist > l_dist[landing_pos] do
              acc
            else
              new_l_paths =
                if dist < l_dist[landing_pos] do
                  Map.put(l_paths, landing_pos, [p_min | paths[p_min]])
                else
                  Map.put(l_paths, landing_pos, [p_min | paths[p_min]])
                end

              new_l_heap = MapSet.put(l_heap, landing_pos)
              new_l_dist = Map.put(l_dist, landing_pos, dist)

              {new_l_heap, new_l_dist, new_l_paths}
            end
          end
        )

      dijkstra(new_heap, new_visited, new_distance, new_paths, grid, finish)
    end
  end

  def print({grid, start, finish, gridr}, path) do
    max_r = max_by(gridr, fn {{r, _}, _} -> r end) |> elem(0) |> elem(0)
    max_c = max_by(gridr, fn {{_, c}, _} -> c end) |> elem(0) |> elem(1)
    ppath = for {pos_min, _move_type, dir, _dist} <- path, into: %{}, do: {pos_min, dir}

    for r <- 0..max_r do
      for c <- 0..max_c do
        p = ppath[{r, c}]

        cond do
          {r, c} == start -> "S"
          {r, c} == finish -> "E"
          p != nil -> %{n: "^", e: ">", s: "v", w: "<"}[p]
          {r, c} in grid -> "."
          true -> "#"
        end
      end
      |> join()
      |> IO.puts()
    end

    nil
  end

  def part1(args) do
    parsed = args |> parse()
    # {dist, path} =
    solve(parsed) |> map(fn {dist, _} -> dist end) |> Enum.min()
    #    print(parsed, path)
    #    dist
  end

  def part2(args) do
    args
  end

  def test(_) do
    """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """
  end

  def test2(_) do
    """
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
    """
  end
end
