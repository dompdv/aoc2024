defmodule AdventOfCode.Day15 do
  import Enum

  ## Print grid
  def print({grid, robot}) do
    maxr = for({{r, _}, _} <- grid, do: r) |> max()
    maxc = for({{_, c}, _} <- grid, do: c) |> max()
    symbols = %{nil => ".", :wall => "#", :box => "O", :lbox => "[", :rbox => "]"}

    for r <- 0..maxr do
      for c <- 0..maxc do
        if {r, c} == robot,
          do: "@",
          else: symbols[Map.get(grid, {r, c})]
      end
      |> join()
      |> IO.puts()
    end

    IO.puts("")
    {grid, robot}
  end

  # Grid Score
  def gps({grid, _}) do
    reduce(grid, 0, fn
      {{r, c}, :box}, acc -> acc + 100 * r + c
      {{r, c}, :lbox}, acc -> acc + 100 * r + c
      _, acc -> acc
    end)
  end

  ## Parse moves
  @dir_symbols %{?< => :left, ?^ => :up, ?> => :right, ?v => :down}
  def parse_moves(moves) do
    for(dir <- to_charlist(moves), do: @dir_symbols[dir]) |> reject(&is_nil/1)
  end

  # Move
  @dirs %{up: {-1, 0}, down: {1, 0}, left: {0, -1}, right: {0, 1}}
  def move({r, c}, dir) do
    {dr, dc} = @dirs[dir]
    {r + dr, c + dc}
  end

  # Run the full simulation
  def run(args, parse, moveable?, push) do
    {initial_state, moves} = args |> parse.()

    reduce(moves, print(initial_state), fn dir, {g, pos} = state ->
      new_pos = move(pos, dir)

      if moveable?.(new_pos, dir, g),
        do: {push.(g, new_pos, dir), new_pos},
        else: state
    end)
    |> print()
    |> gps()
  end

  ## Part 1
  def parse_grid1(grid) do
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

  def parse1(args) do
    [grid, moves] = args |> String.split("\n\n", trim: true)
    {parse_grid1(grid), parse_moves(moves)}
  end

  # Check is a cell is moveable
  def moveable1?(pos, dir, grid) do
    # empty cell is moveable (so to speak: you can move the void)
    # a wall is not moveable
    # a box is moveable if the cell after it in the same direction is moveable
    case Map.get(grid, pos) do
      nil -> true
      :wall -> false
      :box -> moveable1?(move(pos, dir), dir, grid)
    end
  end

  # Push a cell in a direction
  # ie modify the grid accordingly
  def push1(grid, pos, dir) do
    case Map.get(grid, pos) do
      nil ->
        # empty cell, nothing to do
        grid

      :wall ->
        # wall, nothing to do, as you can't move it
        grid

      :box ->
        new_pos = move(pos, dir)
        # If the box is moveable, we move it
        if moveable1?(new_pos, dir, grid) do
          # We push the next cell and we move the box itself
          grid |> push1(new_pos, dir) |> Map.put(pos, nil) |> Map.put(new_pos, :box)
        else
          grid
        end
    end
  end

  def part1(args), do: run(args, &parse1/1, &moveable1?/3, &push1/3)

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

    cond do
      cell == nil ->
        true

      cell == :wall ->
        false

      # Same as part 1 for the left and right directions
      dir == :left or dir == :right ->
        moveable2?(move(pos, dir), dir, grid)

      # For the up and down directions, we need to check if the two cells are moveable
      cell == :lbox ->
        moveable2?(move(pos, dir), dir, grid) and moveable2?(move({r, c + 1}, dir), dir, grid)

      cell == :rbox ->
        moveable2?(move(pos, dir), dir, grid) and moveable2?(move({r, c - 1}, dir), dir, grid)
    end
  end

  def push2(grid, {r, c} = pos, dir) do
    cell = Map.get(grid, pos)

    cond do
      cell == nil ->
        grid

      cell == :wall ->
        grid

      # Same as part 1 for the left and right directions
      dir == :left or dir == :right ->
        new_pos = move(pos, dir)

        if moveable2?(new_pos, dir, grid) do
          grid |> push2(new_pos, dir) |> Map.put(pos, nil) |> Map.put(new_pos, cell)
        else
          grid
        end

      dir == :up or dir == :down ->
        # For the up and down directions, we need to move two cells
        other_cell = if cell == :lbox, do: :rbox, else: :lbox
        shiftc = if cell == :lbox, do: 1, else: -1

        if moveable2?(move(pos, dir), dir, grid) do
          grid
          |> push2(move(pos, dir), dir)
          |> push2(move({r, c + shiftc}, dir), dir)
          |> Map.put(pos, nil)
          |> Map.put(move(pos, dir), cell)
          |> Map.put({r, c + shiftc}, nil)
          |> Map.put(move({r, c + shiftc}, dir), other_cell)
        else
          grid
        end
    end
  end

  def part2(args), do: run(args, &parse2/1, &moveable2?/3, &push2/3)
end
