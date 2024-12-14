defmodule AdventOfCode.Day14 do
  import Enum

  def parse_line(line) do
    [_, px, py, vx, vy] = Regex.scan(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line) |> hd()
    {String.to_integer(px), String.to_integer(py), String.to_integer(vx), String.to_integer(vy)}
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def positivize(a, _b) when a >= 0, do: a
  def positivize(a, b), do: a + b

  def bound(a, b) do
    case rem(a, b) do
      a when a >= 0 -> a
      a -> b + a
    end
  end

  def pos_after({px, py, vx, vy}, t, {ox, oy}) do
    {bound(px + vx * t, ox), bound(py + vy * t, oy)}
  end

  def count_by_quadrant(robots, {ox, oy}) do
    {mid_x, mid_y} = {div(ox, 2), div(oy, 2)}

    Enum.reduce(robots, %{}, fn {x, y}, acc ->
      case {x, y} do
        {x, y} when x < mid_x and y < mid_y -> Map.update(acc, 1, 1, &(&1 + 1))
        {x, y} when x > mid_x and y < mid_y -> Map.update(acc, 2, 1, &(&1 + 1))
        {x, y} when x < mid_x and y > mid_y -> Map.update(acc, 3, 1, &(&1 + 1))
        {x, y} when x > mid_x and y > mid_y -> Map.update(acc, 4, 1, &(&1 + 1))
        _ -> acc
      end
    end)
  end

  def part1(args) do
    grid_size = {101, 103}

    args
    |> parse()
    |> map(&pos_after(&1, 100, grid_size))
    |> count_by_quadrant(grid_size)
    |> reduce(1, fn {_, v}, acc -> acc * v end)
  end

  def part2(args) do
    args
  end

  def test(_) do
    """
    p=0,4 v=3,-3
    p=6,3 v=-1,-3
    p=10,3 v=-1,2
    p=2,0 v=2,-1
    p=0,0 v=1,3
    p=3,0 v=-2,-2
    p=7,6 v=-1,-3
    p=3,0 v=-1,-2
    p=9,3 v=2,3
    p=7,3 v=-1,2
    p=2,4 v=2,-3
    p=9,5 v=-3,-3
    """
  end
end
