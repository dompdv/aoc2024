defmodule AdventOfCode.Day18 do
  import Enum
  @dirs [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
  @big_number 1_000_000_000

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line ->
      line |> String.split(",", trim: true) |> map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  def solve(bytes, grid_size, t) do
    distances =
      for(x <- 0..(grid_size - 1), y <- 0..(grid_size - 1), into: %{}, do: {{x, y}, @big_number})
      |> Map.put({0, 0}, 0)

    visited = MapSet.new()
    heap = MapSet.new([{0, 0}])
    blocks = MapSet.new(take(bytes, t))
    dijkstra(heap, visited, distances, blocks, grid_size)
  end

  def possible_moves({x, y}, visited, blocks, gs) do
    reduce(@dirs, [], fn {dx, dy}, acc ->
      landing = {nx, ny} = {x + dx, y + dy}

      if nx < 0 or ny < 0 or nx >= gs or ny >= gs or landing in visited or landing in blocks,
        do: acc,
        else: [landing | acc]
    end)
  end

  def dijkstra(heap, visited, distances, blocks, grid_size) do
    if MapSet.size(heap) == 0 do
      distances[{grid_size - 1, grid_size - 1}]
    else
      p_min = min_by(heap, fn pos -> distances[pos] end)
      dist_min = distances[p_min]
      new_visited = MapSet.put(visited, p_min)

      p_moves = possible_moves(p_min, new_visited, blocks, grid_size)

      {new_heap, new_distance} =
        reduce(
          p_moves,
          {MapSet.delete(heap, p_min), distances},
          fn landing, {l_heap, l_dist} = acc ->
            dist = dist_min + 1

            if dist >= l_dist[landing] do
              acc
            else
              {MapSet.put(l_heap, landing), Map.put(l_dist, landing, dist)}
            end
          end
        )

      dijkstra(new_heap, new_visited, new_distance, blocks, grid_size)
    end
  end

  def part1(args) do
    args |> parse() |> solve(71, 1024)
  end

  def part2(args) do
    bytes = parse(test(args))
    min_time = solve(bytes, 7, 12)

    blocking =
      reduce_while(1..12, nil, fn t, _acc ->
        if solve(bytes, 7, t) <= min_time, do: {:cont, t}, else: {:halt, t}
      end)

    at(bytes, blocking)
  end

  def test(_) do
    """
    5,4
    4,2
    4,5
    3,0
    2,1
    6,3
    2,4
    1,5
    0,6
    3,3
    2,6
    5,1
    1,2
    5,5
    2,5
    6,5
    1,4
    0,4
    6,4
    1,1
    6,1
    1,0
    0,5
    1,6
    2,0
    """
  end
end
