defmodule AdventOfCode.Day05 do
  import Enum

  def add(m, key, val) do
    case Map.fetch(m, key) do
      {:ok, l} -> Map.put(m, key, [val | l])
      :error -> Map.put(m, key, [val])
    end
  end

  def parse1(p) do
    String.split(p, "\n", trim: true)
    |> reduce(%{}, fn l, acc ->
      [p1, p2] = l |> String.split("|", trim: true) |> map(&String.to_integer/1)
      add(acc, p1, p2)
    end)
  end

  def parse2(p) do
    String.split(p, "\n", trim: true)
    |> map(fn l -> l |> String.split(",", trim: true) |> map(&String.to_integer/1) end)
  end

  def parse(args) do
    [part1, part2] = String.split(args, "\n\n", trim: true)
    {parse1(part1), parse2(part2)}
  end

  def is_before(p1, p2, rules) do
    rules_p1 = Map.get(rules, p1)
    rules_p2 = Map.get(rules, p2)

    cond do
      rules_p1 != nil and p2 in rules_p1 -> true
      rules_p2 != nil and p1 in rules_p2 -> false
      true -> true
    end
  end

  def monotonic(update, rules) do
    ordered = with_index(update)

    for({page1, i} <- ordered, {page2, j} <- ordered, j > i, do: is_before(page1, page2, rules))
    |> all?()
  end

  def middle(l), do: Enum.at(l, div(length(l), 2))

  def part1(args) do
    {rules, updates} = args |> parse()

    reduce(updates, 0, fn update, acc ->
      if monotonic(update, rules), do: acc + middle(update), else: acc
    end)
  end

  def part2(args) do
    {rules, updates} = args |> parse()

    reduce(updates, 0, fn update, acc ->
      if monotonic(update, rules),
        do: acc,
        else: acc + (sort(update, &is_before(&1, &2, rules)) |> middle())
    end)
  end
end
