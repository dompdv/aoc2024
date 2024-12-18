defmodule AdventOfCode.Day16 do
  import Enum

  @dirs %{n: {-1, 0}, e: {0, 1}, s: {1, 0}, w: {0, -1}}
  @big_number 1_000_000_000
  @clockwise %{n: :e, e: :s, s: :w, w: :n}
  @counter_clockwise %{n: :w, w: :s, s: :e, e: :n}

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

  # Moves and turns
  def move({r, c}, dir) do
    {dr, dc} = @dirs[dir]
    {r + dr, c + dc}
  end

  def cw(dir), do: @clockwise[dir]
  def ccw(dir), do: @counter_clockwise[dir]

  # Dijkstra: find the possible moves from a given position, facing a given direction
  # Visited is the MapSet of already visited positions and grid is the map of empty cells
  def possible_moves({cell, facing}, visited, grid) do
    # 3 possible moves: forward, clockwise and counter clockwise
    reduce(
      [{:forward, facing}, {:cw, cw(facing)}, {:ccw, ccw(facing)}],
      [],
      fn {move_type, dir}, acc ->
        {landing, _} = landing_pos = {move(cell, dir), dir}
        # Consider only empty cells and not visited cells
        if landing_pos in visited or landing not in grid,
          do: acc,
          else: [{move_type, {landing, dir}} | acc]
      end
    )
  end

  # Dijkstra: starting the search
  def solve({grid, start, finish, _}) do
    # Initialize distances to a large number, except for the starting position
    # A "node" is not only a position, but also a direction. It's a couple {{row,col}, direction}
    distances =
      for(cell <- grid, dir <- [:n, :e, :s, :w], into: %{}, do: {{cell, dir}, @big_number})
      |> Map.put({start, :e}, 0)

    # Start with an empty visited set and a heap containing only the starting position
    visited = MapSet.new()
    heap = MapSet.new([{start, :e}])
    # Paths is a map of lists of positions, representing the path to reach a given position
    paths = for(cell <- grid, dir <- [:n, :e, :s, :w], into: %{}, do: {{cell, dir}, []})
    # Start the search
    dijkstra(heap, visited, distances, paths, grid, finish)
  end

  def dijkstra(heap, visited, distances, paths, grid, finish) do
    if MapSet.size(heap) == 0 do
      # If the heap is empty, we are done
      # There are potentially 4 distances and paths to the finish, one for each direction (there are 4 finishing states)
      for dir <- [:n, :e, :s, :w], do: {distances[{finish, dir}], reverse(paths[{finish, dir}])}
    else
      # Find the position with the smallest distance in the heap
      p_min = min_by(heap, fn pos -> distances[pos] end)
      dist_min = distances[p_min]

      # Remove it from the heap and add it to the visited set
      new_visited = MapSet.put(visited, p_min)
      # Compute the possible moves from this position
      p_moves = possible_moves(p_min, new_visited, grid)
      # iterate on them

      {new_heap, new_distance, new_paths} =
        reduce(
          p_moves,
          {MapSet.delete(heap, p_min), distances, paths},
          fn {move_type, landing_pos}, {l_heap, l_dist, l_paths} = acc ->
            # When we move, we join in one step to turn and move forward . Thus the 1001
            dist = dist_min + if move_type == :forward, do: 1, else: 1001

            if dist > l_dist[landing_pos] do
              # No need to update the distances, heap and paths
              acc
            else
              # Path so far is the path to the current position
              so_far = paths[p_min]

              new_l_paths =
                cond do
                  # If the distance is smaller, we update the path
                  dist < l_dist[landing_pos] ->
                    Map.put(l_paths, landing_pos, [p_min | so_far])

                  # If the distance is the same, this means that we have several shortest paths. So we store this
                  dist == l_dist[landing_pos] ->
                    current_hd = [l_paths[landing_pos]] |> List.flatten()
                    Map.put(l_paths, landing_pos, [[p_min | current_hd] | so_far])

                  # should not happen
                  true ->
                    l_paths
                end

              # Add the node to the heap
              new_l_heap = MapSet.put(l_heap, landing_pos)
              # Update the distance
              new_l_dist = Map.put(l_dist, landing_pos, dist)

              {new_l_heap, new_l_dist, new_l_paths}
            end
          end
        )

      # Loop until the heap is empty
      dijkstra(new_heap, new_visited, new_distance, new_paths, grid, finish)
    end
  end

  def find_min(l), do: min(map(l, fn {dist, _} -> dist end))

  def part1(args), do: args |> parse() |> solve() |> find_min()

  def find_and_flatten_shortest_path(solution) do
    # We have several  paths to the finish
    # Identify the path with the smallest distance
    short_dist = find_min(solution)

    solution
    # Take the path itself
    |> find(fn {dist, _} -> dist == short_dist end)
    |> elem(1)
    # Flatten it because we can have several shortest paths
    |> List.flatten()
    # Take only the {r,c}
    |> map(&elem(&1, 0))
    # Deduplicate
    |> uniq()
    |> length()
    # Account for the ending position
    |> then(&(&1 + 1))
  end

  def part2(args), do: args |> parse() |> solve() |> find_and_flatten_shortest_path()
end
