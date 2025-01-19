defmodule AdventOfCode.Day24 do
  import Enum

  # Part 1
  def number(<<_::utf8, rest::binary>>), do: String.to_integer(rest)

  def bool_to_int(state, register) do
    reduce(register, 0, fn wire, acc ->
      acc + if state[wire], do: 2 ** number(wire), else: 0
    end)
  end

  def parse1(args) do
    [input, ops] = String.split(args, "\n\n", trim: true)

    {for line <- String.split(ops, "\n", trim: true), into: %{} do
       [_, x, op, y, z] = Regex.scan(~r/(.*) (.*) (.*) -> (.*)/, line) |> hd()
       {z, {x, op, y}}
     end,
     for line <- String.split(input, "\n", trim: true), into: %{} do
       [reg, v] = String.split(line, ": ")
       {reg, v == "1"}
     end}
  end

  def value(state, register, wires) do
    case state[register] do
      nil ->
        {in1, op, in2} = wires[register]

        state = state |> value(in1, wires) |> value(in2, wires)

        Map.put(
          state,
          register,
          case op do
            "AND" -> state[in1] && state[in2]
            "OR" -> state[in1] || state[in2]
            "XOR" -> state[in1] != state[in2]
          end
        )

      _ ->
        state
    end
  end

  def part1(args) do
    {wires, registers} = args |> parse1()
    # identify the output register (z) bits
    z_register = for({k, _} <- wires, String.starts_with?(k, "z"), do: k) |> sort()

    reduce(z_register, registers, fn register, state -> value(state, register, wires) end)
    |> bool_to_int(z_register)
  end

  def parse2(args) do
    [_input, ops] = String.split(args, "\n\n", trim: true)

    reduce(String.split(ops, "\n", trim: true), %{}, fn line, acc ->
      [_, x, op, y, z] = Regex.scan(~r/(.*) (.*) (.*) -> (.*)/, line) |> hd()

      Map.put(acc, z, {x, op, y})
    end)
  end

  def depends(wires, register, m) do
    cond do
      String.starts_with?(register, "x") ->
        {number(register), -1}

      String.starts_with?(register, "y") ->
        {-1, number(register)}

      true ->
        {in1, _, in2} = wires[register]
        {x_in1, y_in1} = depends(wires, in1, m)
        {x_in2, y_in2} = depends(wires, in2, m)
        {Kernel.max(x_in1, x_in2), Kernel.max(y_in1, y_in2)}
    end
  end

  def part2(args) do
    wires = args |> parse2()
    z_register = for({k, _} <- wires, String.starts_with?(k, "z"), do: k)

    for z <- z_register do
      {z, depends(wires, z, number(z))}
    end

    IO.inspect(count(wires))
  end

  def test0(_) do
    """
    x00: 0
    x01: 1
    x02: 0
    x03: 1
    x04: 0
    x05: 1
    y00: 0
    y01: 0
    y02: 1
    y03: 1
    y04: 0
    y05: 1

    x00 AND y00 -> z05
    x01 AND y01 -> z02
    x02 AND y02 -> z01
    x03 AND y03 -> z03
    x04 AND y04 -> z04
    x05 AND y05 -> z00
    """
  end

  def test1(_) do
    """
    x00: 0
    x01: 1
    x02: 0
    x03: 1
    x04: 0
    x05: 1
    y00: 0
    y01: 0
    y02: 1
    y03: 1
    y04: 0
    y05: 1

    x00 AND y00 -> z00
    x01 AND y01 -> z01
    x02 AND y02 -> z02
    x03 AND y03 -> z03
    x04 AND y04 -> z04
    x05 AND y05 -> z05
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
