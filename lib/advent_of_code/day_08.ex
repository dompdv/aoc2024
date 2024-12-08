defmodule AdventOfCode.Day08 do
  import Enum

  def add(m, key, val) do
    case Map.fetch(m, key) do
      {:ok, l} -> Map.put(m, key, [val | l])
      :error -> Map.put(m, key, [val])
    end
  end

  def parse(args) do
    splitted = args |> String.split("\n", trim: true)

    board =
      splitted
      |> with_index()
      |> map(fn {line, r} ->
        line |> to_charlist() |> with_index() |> map(fn {ch, c} -> {{r, c}, ch} end)
      end)
      |> List.flatten()
      |> reduce(%{}, fn {{r, c}, ch}, acc ->
        if ch == ?. or ch == ?#, do: acc, else: add(acc, ch, {r, c})
      end)

    {board, length(splitted)}
  end

  def in_grid({r, c}, grid_size) do
    r >= 0 and r < grid_size and c >= 0 and c < grid_size
  end

  def antinodes(positions, grid_size) do
    indexed = with_index(positions)

    for {{r1, c1}, i} <- indexed, {{r2, c2}, j} <- indexed, i < j do
      {dr, dc} = {r2 - r1, c2 - c1}

      [{r2 + dr, c2 + dc}, {r1 - dr, c1 - dc}] |> filter(&in_grid(&1, grid_size))
    end
  end

  def beam({r, c}, {dr, dc} = delta, grid_size) do
    new_pos = {r + dr, c + dc}

    if in_grid(new_pos, grid_size),
      do: [new_pos | beam(new_pos, delta, grid_size)],
      else: []
  end

  def antinodes2(positions, grid_size) do
    indexed = with_index(positions)

    for {{r1, c1}, i} <- indexed, {{r2, c2}, j} <- indexed, i < j do
      {dr, dc} = {r2 - r1, c2 - c1}
      [beam({r1, c1}, {dr, dc}, grid_size), beam({r2, c2}, {-dr, -dc}, grid_size)]
    end
  end

  def number_antinodes(args, find_antinodes) do
    {city, grid_size} = args |> parse()

    city
    |> reduce([], fn {_letter, positions}, acc ->
      [find_antinodes.(positions, grid_size) | acc]
    end)
    |> List.flatten()
    |> uniq()
    |> length()
  end

  def part1(args), do: number_antinodes(args, &antinodes/2)
  def part2(args), do: number_antinodes(args, &antinodes2/2)
end
