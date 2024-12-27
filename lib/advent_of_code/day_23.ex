defmodule AdventOfCode.Day23 do
  import Enum

  def parse(args) do
    links =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "-"))
      |> reduce(%{}, fn [a, b], acc ->
        acc |> Map.update(a, [], fn v -> [b | v] end) |> Map.update(b, [], fn v -> [a | v] end)
      end)

    nodes = for({k, v} <- links, do: [k, v]) |> List.flatten() |> uniq()
    {nodes, links}
  end

  def part1(args) do
    {nodes, links} = args |> test() |> parse()
  end

  def part2(args) do
    args
  end

  def test(_) do
    """
    kh-tc
    qp-kh
    de-cg
    ka-co
    yn-aq
    qp-ub
    cg-tb
    vc-aq
    tb-ka
    wh-tc
    yn-cg
    kh-ub
    ta-co
    de-co
    tc-td
    tb-wq
    wh-td
    ta-ka
    td-qp
    aq-cg
    wq-ub
    ub-vc
    de-ta
    wq-aq
    wq-vc
    wh-yn
    ka-de
    kh-ta
    co-tc
    wh-qp
    tb-vc
    td-yn
    """
  end
end
