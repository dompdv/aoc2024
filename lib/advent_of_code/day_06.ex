defmodule AdventOfCode.Day06 do
  import Enum

  def parse(args) do
    String.split(args, "\n", trim: true)
    |> with_index()
    |> map(fn {l, r} ->
      l |> to_charlist() |> with_index() |> map(fn {ch, col} -> {{r, col}, ch} end)
    end)
    |> List.flatten()
    |> reduce({%{}, nil}, fn
      {p, ?.}, {board, guard} -> {Map.put(board, p, :empty), guard}
      {p, ?#}, {board, guard} -> {Map.put(board, p, :block), guard}
      {p, ?^}, {board, _} -> {Map.put(board, p, :empty), {p, :n}}
      {p, ?>}, {board, _} -> {Map.put(board, p, :empty), {p, :e}}
      {p, ?v}, {board, _} -> {Map.put(board, p, :empty), {p, :s}}
      {p, ?<}, {board, _} -> {Map.put(board, p, :empty), {p, :w}}
    end)
  end

  def turn_right(d), do: %{:n => :e, :e => :s, :s => :w, :w => :n}[d]

  @moves %{n: {-1, 0}, e: {0, 1}, s: {1, 0}, w: {0, -1}}

  def move({board, {{r, c}, dir}}) do
    {dr, dc} = @moves[dir]
    new_pos = {r + dr, c + dc}

    case board[new_pos] do
      nil -> :out
      :empty -> {board, {new_pos, dir}}
      :block -> {board, {{r, c}, turn_right(dir)}}
    end
  end

  def get_pos({_, pos}), do: pos

  def run(state, seen) do
    case move(state) do
      :out ->
        seen

      new_state ->
        if get_pos(new_state) in seen,
          do: :loop,
          else: run(new_state, MapSet.put(seen, get_pos(new_state)))
    end
  end

  def count_cells(seen) do
    for({p, _} <- seen, do: p) |> uniq() |> length()
  end

  def part1(args) do
    state = args |> parse()
    run(state, MapSet.new([get_pos(state)])) |> count_cells()
  end

  def part2(args) do
    {board, guard} = args |> parse()
    cells = Map.keys(board)
    {starting, _} = guard

    for cell <- cells, cell != starting do
      if run({Map.put(board, cell, :block), guard}, MapSet.new([guard])) == :loop, do: 1, else: 0
    end
    |> sum()
  end
end
