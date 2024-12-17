defmodule AdventOfCode.Day16 do
  import Enum

  #  @possible_turns %{n: [:e, :w], e: [:s, :n], s: [:w, :e], w: [:n, :s]}
  @dirs %{n: {-1, 0}, e: {0, 1}, s: {1, 0}, w: {0, -1}}
  @big_number 1_000_000_000
  @clockwise %{n: :e, e: :s, s: :w, w: :n}
  @counter_clockwise %{n: :w, w: :s, s: :e, e: :n}
  def parse(grid) do
    grid
    |> String.split("\n", trim: true)
    |> with_index()
    |> flat_map(fn {row, r} ->
      row
      |> to_charlist()
      |> with_index()
      |> map(fn {cell, c} -> {{r, c}, cell} end)
    end)
    |> reduce({MapSet.new(), nil, nil}, fn e, {grid, start, finish} ->
      case e do
        {_pos, ?#} -> {grid, start, finish}
        {pos, ?.} -> {MapSet.put(grid, pos), start, finish}
        {pos, ?S} -> {MapSet.put(grid, pos), pos, finish}
        {pos, ?E} -> {MapSet.put(grid, pos), start, pos}
      end
    end)
  end

  def move({r, c}, dir) do
    {dr, dc} = @dirs[dir]
    {r + dr, c + dc}
  end

  def cw(dir), do: @clockwise[dir]
  def ccw(dir), do: @counter_clockwise[dir]

  def possible_moves({cell, facing}, queue, grid) do
    reduce(
      [{:forward, facing}, {:turn, cw(facing)}, {:turn, ccw(facing)}],
      [],
      fn {move_type, dir}, acc ->
        landing = move(cell, dir)

        if landing not in queue or landing not in grid,
          do: acc,
          else: [{move_type, dir, landing} | acc]
      end
    )
    |> sort(fn {_, _, landing1}, {_, _, landing2} -> landing1 >= landing2 end)
  end

  def solve({grid, start, finish}) do
    distances =
      for(cell <- grid, into: %{}, do: {cell, {@big_number, nil}}) |> Map.put(start, {0, :e})

    queue = distances |> Map.keys() |> MapSet.new()

    djikstra(queue, distances, grid, finish)
  end

  def djikstra(queue, distances, grid, finish) do
    pos_min = min_by(queue, fn pos -> distances[pos] |> elem(0) end)

    {dist_min, dir_min} = distances[pos_min]

    if pos_min == finish do
      dist_min
    else
      new_queue = MapSet.delete(queue, pos_min)
      p_moves = possible_moves({pos_min, dir_min}, new_queue, grid)

      new_distance =
        reduce(p_moves, distances, fn {move_type, dir, landing}, acc ->
          dist = dist_min + if move_type == :forward, do: 1, else: 1001

          if dist < elem(acc[landing], 0),
            do: Map.put(acc, landing, {dist, dir}),
            else: acc
        end)

      djikstra(new_queue, new_distance, grid, finish)
    end
  end

  def part1(args) do
    args |> parse() |> solve()
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
