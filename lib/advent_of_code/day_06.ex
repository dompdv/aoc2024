defmodule AdventOfCode.Day06 do
  import Enum

  @dir_symbols %{?^ => :n, ?> => :e, ?v => :s, ?< => :w}
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
      {p, dir}, {board, _} -> {Map.put(board, p, :empty), {p, @dir_symbols[dir]}}
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

  def launch(state), do: run(state, MapSet.new([get_pos(state)]))

  def run(state, seen) do
    case move(state) do
      :out ->
        seen

      new_state ->
        new_pos = get_pos(new_state)

        if new_pos in seen,
          do: :loop,
          else: run(new_state, MapSet.put(seen, new_pos))
    end
  end

  def loop?(state), do: launch(state) == :loop

  def count_cells(seen) do
    for({p, _} <- seen, do: p) |> uniq() |> length()
  end

  def part1(args) do
    state = args |> parse()
    launch(state) |> count_cells()
  end

  def part2(args) do
    {board, guard} = args |> parse()
    {starting, _} = guard

    board
    |> Map.keys()
    |> filter(fn cell -> cell != starting and board[cell] == :empty end)
    # Speep up by computing on each CPU cores in parallel
    |> Task.async_stream(fn cell -> loop?({Map.put(board, cell, :block), guard}) end)
    |> Stream.filter(fn {:ok, v} -> v != false end)
    |> count()
  end
end
