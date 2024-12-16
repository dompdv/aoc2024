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
        {_pos, ?.} -> {grid, start, finish}
        {pos, ?#} -> {MapSet.put(grid, pos), start, finish}
        {pos, ?S} -> {grid, pos, finish}
        {pos, ?E} -> {grid, start, pos}
      end
    end)
  end

  def move({r, c}, dir) do
    {dr, dc} = @dirs[dir]
    {r + dr, c + dc}
  end

  def cw(dir), do: @clockwise[dir]
  def ccw(dir), do: @counter_clockwise[dir]

  def possible_moves({cell, facing}, seen, grid) do
    reduce(
      [{:forward, facing}, {:cw, cw(facing)}, {:ccw, ccw(facing)}],
      [],
      fn {move_type, dir}, acc ->
        landing = move(cell, dir)

        if landing in seen or landing in grid,
          do: acc,
          else: [{move_type, dir, landing} | acc]
      end
    )
    |> sort(fn {_, _, landing1}, {_, _, landing2} -> landing1 >= landing2 end)
  end

  def solve({grid, start, finish}) do
    solve({start, :e}, MapSet.new([start]), 0, @big_number, {grid, finish}, [])
  end

  def solve({cell, _}, _seen, current_score, _current_min, {_grid, cell}, path) do
    IO.inspect({current_score, reverse(path)}, label: "Path")
    # IO.inspect(current_score, label: "Path")
    current_score
  end

  def solve(_, _seen, current_score, current_min, _, _path) when current_score >= current_min,
    do: current_min

  def solve(pos, seen, current_score, current_min, {grid, _finish} = fgrid, path) do
    if :rand.uniform() < 0.000001 do
      IO.inspect({pos, current_score, length(path)}, label: "solve")
    end

    possible_moves(pos, seen, grid)
    |> reduce(
      current_min,
      fn {move_type, new_dir, landing}, cc_min ->
        new_score = current_score + if move_type == :forward, do: 1, else: 1001

        if new_score >= cc_min do
          cc_min
        else
          new_seen = MapSet.put(seen, landing)

          current_score =
            solve({landing, new_dir}, new_seen, new_score, cc_min, fgrid, [
              {move_type, new_dir, landing} | path
            ])

          Kernel.min(current_score, cc_min)
        end
      end
    )
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
