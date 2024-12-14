defmodule AdventOfCode.Day14 do
  import Enum

  # Parsing
  def parse_line(line) do
    [_, px, py, vx, vy] = Regex.scan(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line) |> hd()
    {String.to_integer(px), String.to_integer(py), String.to_integer(vx), String.to_integer(vy)}
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  # Moves

  def move_for(robots, t, grid_size) when is_list(robots) do
    map(robots, fn robot -> move_for(robot, t, grid_size) end)
  end

  def move_for({px, py, vx, vy}, t, {ox, oy}) do
    {bound(px + vx * t, ox), bound(py + vy * t, oy)}
  end

  def bound(a, b) do
    case rem(a, b) do
      a when a >= 0 -> a
      a -> a + b
    end
  end

  ## Part 1
  def limit(a, b) when a < b, do: 0
  def limit(_a, _b), do: 1

  def quadrant({x, y}, {mid_x, mid_y}) do
    if x == mid_x or y == mid_y, do: nil, else: limit(x, mid_x) * 2 + limit(y, mid_y)
  end

  def count_by_quadrant(robots, {ox, oy}) do
    mid = {div(ox, 2), div(oy, 2)}
    for(pos <- robots, do: quadrant(pos, mid)) |> frequencies() |> Map.delete(nil)
  end

  def multiply(map), do: reduce(map, 1, fn {_, v}, acc -> acc * v end)

  def part1(args) do
    grid_size = {101, 103}
    args |> parse() |> move_for(100, grid_size) |> count_by_quadrant(grid_size) |> multiply()
  end

  ### Part 2
  def print_grid(robots, grid_size) do
    {ox, oy} = grid_size

    for y <- 0..(oy - 1), into: "" do
      for x <- 0..(ox - 1), into: "" do
        if Enum.any?(robots, fn {rx, ry} -> rx == x and ry == y end),
          do: "#",
          else: "."
      end
    end
    |> IO.puts()

    IO.puts("")
  end

  # Separate the robots into 3 bands: left, middle, right
  def bands(robots, {ox, _oy}) do
    n = length(robots)
    {left_x, right_x} = {div(ox, 4), ox - div(ox, 4)}

    robots
    |> Enum.reduce(%{1 => 0, 2 => 0, 3 => 0}, fn {x, _y}, acc ->
      case x do
        x when x < left_x -> Map.update(acc, 1, 1, &(&1 + 1))
        x when x > right_x -> Map.update(acc, 3, 1, &(&1 + 1))
        _ -> Map.update(acc, 2, 1, &(&1 + 1))
      end
    end)
    |> then(fn b -> b[1] + b[3] < div(n, 4) end)
  end

  def part2(args) do
    grid_size = {101, 103}
    start_pos = args |> parse()

    # Trial & error, guided by the fact that we hope that most of the robots will be in the middle band
    reduce(6200..6300, nil, fn t, acc ->
      robots = start_pos |> move_for(t, grid_size)

      if bands(robots, grid_size) do
        print_grid(robots, grid_size)

        t |> IO.inspect(label: "time")
      else
        acc
      end
    end)

    # then use your eyes to find the correct time
    reduce(6200..6400, nil, fn t, _acc ->
      robots = start_pos |> move_for(t, grid_size)
      IO.inspect(t, label: "time")
      print_grid(robots, grid_size)
      Process.sleep(100)
    end)
  end
end
