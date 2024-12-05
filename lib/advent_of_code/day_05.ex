defmodule AdventOfCode.Day05 do
  import Enum

  def parse1(p) do
    p
    |> String.split("\n", trim: true)
    |> reduce(%{}, fn l, acc ->
      [p1, p2] = l |> String.split("|", trim: true) |> map(&String.to_integer/1)

      case Map.fetch(acc, p1) do
        {:ok, l} -> Map.put(acc, p1, [p2 | l])
        :error -> Map.put(acc, p1, [p2])
      end
    end)
  end

  def parse2(p) do
    p
    |> String.split("\n", trim: true)
    |> map(fn l -> l |> String.split(",", trim: true) |> map(&String.to_integer/1) end)
  end

  def parse(args) do
    [part1, part2] = String.split(args, "\n\n", trim: true)
    {parse1(part1), parse2(part2)}
  end

  def is_before1(p1, p2, rules) do
    rules_p1 = Map.get(rules, p1)
    rules_p2 = Map.get(rules, p2)

    cond do
      rules_p1 != nil and p2 in rules_p1 -> true
      rules_p2 != nil and p1 in rules_p2 -> false
      true -> true
    end
  end

  def control(update, rules) do
    ordered = with_index(update)

    for({page1, i} <- ordered, {page2, j} <- ordered, j > i, do: is_before1(page1, page2, rules))
    |> all?()
  end

  def part1(args) do
    {rules, updates} = args |> parse()

    updates
    |> map(fn update ->
      if control(update, rules), do: Enum.at(update, div(length(update), 2)), else: 0
    end)
    |> sum()
  end

  def part2(args) do
    args
  end

  def test(_) do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end
end
