defmodule AdventOfCode.Day23 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> reduce(MapSet.new([]), fn line, acc ->
      [a, b] = String.split(line, "-")
      if a < b, do: MapSet.put(acc, {a, b}), else: MapSet.put(acc, {b, a})
    end)
  end

  def starts_with_t(l) do
    any?(l, &String.starts_with?(&1, "t"))
  end

  def part1(args) do
    links = parse(args)

    for(
      {a, b} <- links,
      {c, d} <- links,
      b == c,
      {a, d} in links,
      starts_with_t([a, b, d]),
      do: 1
    )
    |> sum()
  end

  def parse2(args) do
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

  def connected_components(node, links) do
    cc(MapSet.new(), node, links)
  end

  def cc(current_cc, node, link) do
    reduce(link[node], MapSet.put(current_cc, node), fn n, acc ->
      if n in acc, do: acc, else: cc(acc, n, link)
    end)
  end

  def part2(args) do
    {nodes, links} = args |> test() |> parse2()
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
