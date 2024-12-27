defmodule AdventOfCode.Day24 do
  import Enum

  def parse(args) do
    args |> String.split("\n", trim: true) |> reduce(%{}, fn line, acc -> parse(line, acc) end)
  end

  def parse("", acc), do: acc

  def parse(line, acc) do
    if String.contains?(line, ":") do
      [key, value] = String.split(line, ": ")
      res = value == "1"
      f = fn state -> {Map.put(state, key, res), res} end
      Map.put(acc, key, f)
    else
      [_, x, op, y, z] = Regex.scan(~r/(.*) (.*) (.*) -> (.*)/, line) |> hd()

      f_op =
        case op do
          "AND" -> fn x, y -> x && y end
          "OR" -> fn x, y -> x || y end
          "XOR" -> fn x, y -> x != y end
        end

      f =
        fn state ->
          c_x = Map.get(state, x)
          {state, x} = if is_function(c_x), do: c_x.(state), else: {state, c_x}
          c_y = Map.get(state, y)
          {state, y} = if is_function(c_y), do: c_y.(state), else: {state, c_y}
          res = f_op.(x, y)
          {Map.put(state, z, res), res}
        end

      Map.put(acc, z, f)
    end
  end

  def set_value(wires, key, value) do
    Map.put(wires, key, fn state -> {Map.put(state, key, value), value} end)
  end

  def set_operation(wires, x, op, y, z) do
    f_op =
      case op do
        "AND" -> fn x, y -> x && y end
        "OR" -> fn x, y -> x || y end
        "XOR" -> fn x, y -> x != y end
      end

    f =
      fn state ->
        c_x = Map.get(state, x)
        {state, x} = if is_function(c_x), do: c_x.(state), else: {state, c_x}
        c_y = Map.get(state, y)
        {state, y} = if is_function(c_y), do: c_y.(state), else: {state, c_y}
        res = f_op.(x, y)
        {Map.put(state, z, res), res}
      end

    Map.put(wires, z, f)
  end

  def part1(args) do
    initial_wires = args |> parse()
    zedes = for {k, _} <- initial_wires, String.starts_with?(k, "z"), do: k

    final_wires =
      reduce(zedes, initial_wires, fn wires, acc ->
        {new_acc, _} = Map.get(acc, wires).(acc)
        new_acc
      end)

    reduce(zedes, 0, fn z, acc ->
      "z" <> r = z
      r = String.to_integer(r)
      acc + if final_wires[z], do: 2 ** r, else: 0
    end)
  end

  def part2(args) do
    args
  end

  def test1(_) do
    """
    x00: 1
    x01: 1
    x02: 1
    y00: 0
    y01: 1
    y02: 0

    x00 AND y00 -> z00
    x01 XOR y01 -> z01
    x02 OR y02 -> z02
    """
  end

  def test2(_) do
    """
    x00: 1
    x01: 0
    x02: 1
    x03: 1
    x04: 0
    y00: 1
    y01: 1
    y02: 1
    y03: 1
    y04: 1

    ntg XOR fgs -> mjb
    y02 OR x01 -> tnw
    kwq OR kpj -> z05
    x00 OR x03 -> fst
    tgd XOR rvg -> z01
    vdt OR tnw -> bfw
    bfw AND frj -> z10
    ffh OR nrd -> bqk
    y00 AND y03 -> djm
    y03 OR y00 -> psh
    bqk OR frj -> z08
    tnw OR fst -> frj
    gnj AND tgd -> z11
    bfw XOR mjb -> z00
    x03 OR x00 -> vdt
    gnj AND wpb -> z02
    x04 AND y00 -> kjc
    djm OR pbm -> qhw
    nrd AND vdt -> hwm
    kjc AND fst -> rvg
    y04 OR y02 -> fgs
    y01 AND x02 -> pbm
    ntg OR kjc -> kwq
    psh XOR fgs -> tgd
    qhw XOR tgd -> z09
    pbm OR djm -> kpj
    x03 XOR y03 -> ffh
    x00 XOR y04 -> ntg
    bfw OR bqk -> z06
    nrd XOR fgs -> wpb
    frj XOR qhw -> z04
    bqk OR frj -> z07
    y03 OR x01 -> nrd
    hwm AND bqk -> z03
    tgd XOR rvg -> z12
    tnw OR pbm -> gnj
    """
  end
end
