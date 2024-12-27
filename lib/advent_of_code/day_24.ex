defmodule AdventOfCode.Day24 do
  import Enum

  def parse(args) do
    args |> String.split("\n", trim: true) |> reduce(%{}, fn line, acc -> parse(line, acc) end)
  end

  def parse("", acc), do: acc

  def parse(line, acc) do
    if String.contains?(line, ":") do
      [key, value] = String.split(line, ": ")
      set_value(acc, key, value == "1")
    else
      [_, x, op, y, z] = Regex.scan(~r/(.*) (.*) (.*) -> (.*)/, line) |> hd()
      set_operation(acc, x, op, y, z)
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

  def number(<<_::utf8, rest::binary>>), do: String.to_integer(rest)

  def bool_to_int(wires, registers, register) do
    reduce(registers[register], 0, fn wire, acc ->
      acc + if wires[wire], do: 2 ** number(wire), else: 0
    end)
  end

  def part1(args) do
    initial_wires = args |> parse()
    registers = %{"z" => for({k, _} <- initial_wires, String.starts_with?(k, "z"), do: k)}

    final_wires =
      reduce(registers["z"], initial_wires, fn wires, acc ->
        {new_acc, _} = Map.get(acc, wires).(acc)
        new_acc
      end)

    bool_to_int(final_wires, registers, "z")
  end

  def part2(args) do
    args
  end
end
