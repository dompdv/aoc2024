defmodule AdventOfCode.Day15 do
  import Enum

  def parse_grid(grid) do
    grid
    |> String.split("\n", trim: true)
    |> with_index()
    |> flat_map(fn {row, r} ->
      row
      |> to_charlist()
      |> with_index()
      |> map(fn {cell, c} -> {{r, c}, cell} end)
    end)
    |> reduce({%{}, nil}, fn e, {grid, robot} ->
      case e do
        {_pos, ?.} -> {grid, robot}
        {pos, ?#} -> {Map.put(grid, pos, :wall), robot}
        {pos, ?O} -> {Map.put(grid, pos, :box), robot}
        {pos, ?@} -> {grid, pos}
      end
    end)
  end

  def parse_moves(moves) do
    moves
    |> to_charlist()
    |> reduce([], fn
      ?<, acc -> [:left | acc]
      ?^, acc -> [:up | acc]
      ?>, acc -> [:right | acc]
      ?v, acc -> [:down | acc]
      _, acc -> acc
    end)
    |> reverse()
  end

  def parse(args) do
    [grid, moves] = args |> String.split("\n\n", trim: true)
    {parse_grid(grid), parse_moves(moves)}
  end

  def print(robot, grid) do
    {max_r, max_c} =
      grid
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {r, c}, {max_r, max_c} ->
        {Kernel.max(r, max_r), Kernel.max(c, max_c)}
      end)

    for r <- 0..max_r do
      for c <- 0..max_c do
        if {r, c} == robot do
          "@"
        else
          case Map.get(grid, {r, c}) do
            nil -> "."
            :wall -> "#"
            :box -> "O"
            :lbox -> "["
            :rbox -> "]"
          end
        end
      end
      |> join()
      |> IO.puts()
    end

    IO.puts("")
  end

  @dirs %{up: {-1, 0}, down: {1, 0}, left: {0, -1}, right: {0, 1}}
  def move({r, c}, dir) do
    {dr, dc} = @dirs[dir]
    {r + dr, c + dc}
  end

  def moveable?(pos, dir, grid) do
    case Map.get(grid, pos) do
      nil -> true
      :wall -> false
      :box -> moveable?(move(pos, dir), dir, grid)
    end
  end

  def push(grid, pos, dir) do
    case Map.get(grid, pos) do
      nil ->
        grid

      :wall ->
        grid

      :box ->
        new_pos = move(pos, dir)

        if moveable?(new_pos, dir, grid) do
          grid |> push(new_pos, dir) |> Map.put(pos, nil) |> Map.put(new_pos, :box)
        else
          grid
        end
    end
  end

  def gps({_, grid}) do
    reduce(grid, 0, fn
      {{r, c}, :box}, acc -> acc + 100 * r + c
      _, acc -> acc
    end)
  end

  def part1(args) do
    {{grid, robot}, moves} = args |> parse()

    reduce(moves, {robot, grid}, fn dir, {pos, g} ->
      new_pos = move(pos, dir)

      if moveable?(new_pos, dir, g) do
        {new_pos, push(g, new_pos, dir)}
      else
        {pos, g}
      end
    end)
    |> gps()
  end

  ### PART2
  def parse_grid2(grid) do
    grid
    |> String.split("\n", trim: true)
    |> with_index()
    |> flat_map(fn {row, r} ->
      row
      |> to_charlist()
      |> with_index()
      |> map(fn {cell, c} -> {{r, c}, cell} end)
    end)
    |> reduce({%{}, nil}, fn e, {grid, robot} ->
      case e do
        {_pos, ?.} ->
          {grid, robot}

        {{r, c}, ?#} ->
          {grid |> Map.put({r, 2 * c}, :wall) |> Map.put({r, 2 * c + 1}, :wall), robot}

        {{r, c}, ?O} ->
          {grid |> Map.put({r, 2 * c}, :lbox) |> Map.put({r, 2 * c + 1}, :rbox), robot}

        {{r, c}, ?@} ->
          {grid, {r, 2 * c}}
      end
    end)
  end

  def parse2(args) do
    [grid, moves] = args |> String.split("\n\n", trim: true)
    {parse_grid2(grid), parse_moves(moves)}
  end

  def moveable2?({r, c} = pos, dir, grid) do
    cell = Map.get(grid, pos)

    IO.inspect({pos, cell, dir}, label: "moveable2?")

    cond do
      cell == nil ->
        true

      cell == :wall ->
        false

      cell == :lbox and dir == :right ->
        moveable2?({r, c + 2}, dir, grid)

      cell == :rbox and dir == :right ->
        moveable2?({r, c + 1}, dir, grid)

      cell == :lbox and dir == :left ->
        moveable2?({r, c - 1}, dir, grid)

      cell == :rbox and dir == :left ->
        moveable2?({r, c - 2}, dir, grid)

      cell == :lbox and dir == :up ->
        moveable2?({r - 1, c}, dir, grid) and moveable2?({r - 1, c + 1}, dir, grid)

      cell == :rbox and dir == :up ->
        moveable2?({r - 1, c}, dir, grid) and moveable2?({r - 1, c - 1}, dir, grid)

      cell == :lbox and dir == :down ->
        moveable2?({r + 1, c}, dir, grid) and moveable2?({r + 1, c + 1}, dir, grid)

      cell == :rbox and dir == :down ->
        moveable2?({r + 1, c}, dir, grid) and moveable2?({r + 1, c - 1}, dir, grid)
    end
  end

  def push2(grid, {r, c} = pos, dir) do
    cell = Map.get(grid, pos)

    cond do
      cell == nil ->
        grid

      cell == :wall ->
        grid

      (cell == :lbox or cell == :rbox) and (dir == :up or dir == :down) ->
        other_cell = if cell == :lbox, do: :rbox, else: :lbox
        shiftc = if cell == :lbox, do: 1, else: -1
        shiftr = if dir == :up, do: -1, else: 1

        if moveable2?({r + shiftr, c}, dir, grid) do
          grid
          |> push2({r + shiftr, c}, dir)
          |> push2({r + shiftr, c + shiftc}, dir)
          |> Map.put(pos, nil)
          |> Map.put({r + shiftr, c}, cell)
          |> Map.put({r, c + shiftc}, nil)
          |> Map.put({r + shiftr, c + shiftc}, other_cell)
        else
          grid
        end

      true ->
        new_pos = move(pos, dir)

        if moveable2?(new_pos, dir, grid) do
          grid |> push2(new_pos, dir) |> Map.put(pos, nil) |> Map.put(new_pos, cell)
        else
          grid
        end
    end
  end

  def gps2({_, grid}) do
    reduce(grid, 0, fn
      {{r, c}, :lbox}, acc -> acc + 100 * r + c
      _, acc -> acc
    end)
  end

  def part2(args) do
    {{grid, robot}, moves} = args |> parse2()
    print(robot, grid)

    reduce(moves, {robot, grid}, fn dir, {pos, g} ->
      new_pos = move(pos, dir)

      {np, ng} =
        if moveable2?(new_pos, dir, g) do
          {new_pos, push2(g, new_pos, dir)}
        else
          {pos, g}
        end

      {np, ng}
    end)
    |> gps2()
  end

  def test(_) do
    """
    ########
    #..O.O.#
    ##@.O..#
    #...O..#
    #.#.O..#
    #...O..#
    #......#
    ########

    <^^>>>vv<v>>v<<
    """
  end

  def test2(_) do
    """
    ##########
    #..O..O.O#
    #......O.#
    #.OO..O.O#
    #..O@..O.#
    #O#..O...#
    #O..O..O.#
    #.OO.O.OO#
    #....O...#
    ##########

    <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
    """
  end

  def test3(_) do
    """
    #######
    #...#.#
    #.....#
    #..OO@#
    #..O..#
    #.....#
    #######

    <vv<<^^<<^^
    """
  end
end
