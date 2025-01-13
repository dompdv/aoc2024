defmodule AdventOfCode.Day23 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> reduce(MapSet.new([]), fn line, acc ->
      [a, b] = String.split(line, "-")
      # Build a set of {a, b} ORDERED pairs
      if a < b, do: MapSet.put(acc, {a, b}), else: MapSet.put(acc, {b, a})
    end)
  end

  def part1(args) do
    links = parse(args)
    # Go through all couple of links and check if there is a third link that
    # connects the first and the last node of the first two links
    for(
      {a, b} <- links,
      {c, d} <- links,
      b == c,
      {a, d} in links,
      any?([a, b, d], &String.starts_with?(&1, "t")),
      do: 1
    )
    |> sum()
  end

  def parse2(args) do
    # Create 3 structures:
    # - a map %{node => list of connected nodes}
    # - a set of all {a,b} and {b,a} pairs. This is used to check quickly if two nodes are connected
    # - a set of all nodes
    args
    |> String.split("\n", trim: true)
    |> reduce({%{}, MapSet.new(), MapSet.new()}, fn line, {l_links, l_search, l_nodes} ->
      [a, b] = String.split(line, "-")

      {l_links
       |> Map.update(a, [], fn v -> [b | v] end)
       |> Map.update(b, [], fn v -> [a | v] end),
       l_search |> MapSet.put({a, b}) |> MapSet.put({b, a}),
       l_nodes |> MapSet.put(a) |> MapSet.put(b)}
    end)
  end

  def connected_components(node, links, search), do: cc(MapSet.new(), node, links, search)

  # Find a fully connected component starting from a node
  # recursively add all connected nodes to the current connected component
  # provided that the new added node is already connected to the current connected component
  def cc(current_cc, node, link, search) do
    reduce(link[node], MapSet.put(current_cc, node), fn n, acc ->
      cond do
        # already in the connected component
        n in acc -> acc
        # not connected to all nodes in the connected component
        any?(acc, fn other -> {n, other} not in search end) -> acc
        # add the node to the connected component and recurse
        true -> cc(acc, n, link, search)
      end
    end)
  end

  def part2(args) do
    {links, search, nodes} = args |> parse2()

    # Find the connected component of all nodes and keep the biggest one
    {_, max_cc} =
      reduce(nodes, {0, nil}, fn node, {current_max, current_max_cc} ->
        cc = connected_components(node, links, search)
        s = MapSet.size(cc)
        if s > current_max, do: {s, cc}, else: {current_max, current_max_cc}
      end)

    max_cc |> MapSet.to_list() |> sort() |> join(",")
  end
end
