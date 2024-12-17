defmodule AdventOfCode.Day17 do
  import Enum

  # Yes, I like to parse the input nicely, in a readable format
  def parse_register(registers) do
    registers
    |> String.split("\n", trim: true)
    |> map(fn line ->
      [r, v] = line |> String.replace("Register ", "") |> String.split(": ", trim: true)
      {String.to_atom(r), String.to_integer(v)}
    end)
    |> Enum.into(%{})
  end

  def parse_program(program) do
    program
    |> String.replace("Program: ", "")
    |> String.split(",", trim: true)
    |> map(&String.to_integer/1)
    |> parse_instruction()
    |> with_index(fn element, index -> {2 * index, element} end)
    |> Map.new()
  end

  def raw_program(p) do
    p
    |> String.split(": ", trim: true)
    |> at(1)
    |> String.split(",", trim: true)
    |> map(&String.to_integer/1)
  end

  # Like this
  def parse_instruction(l), do: parse_instruction(l, [])

  def parse_instruction([], acc), do: reverse(acc)

  def parse_instruction([0, ope | rest], acc),
    do: parse_instruction(rest, [{:adv, combo(ope)} | acc])

  def parse_instruction([6, ope | rest], acc),
    do: parse_instruction(rest, [{:bdv, combo(ope)} | acc])

  def parse_instruction([7, ope | rest], acc),
    do: parse_instruction(rest, [{:cdv, combo(ope)} | acc])

  def parse_instruction([1, ope | rest], acc),
    do: parse_instruction(rest, [{:bxl, {:lit, ope}} | acc])

  def parse_instruction([2, ope | rest], acc),
    do: parse_instruction(rest, [{:bst, combo(ope)} | acc])

  def parse_instruction([3, ope | rest], acc),
    do: parse_instruction(rest, [{:jnz, {:lit, ope}} | acc])

  def parse_instruction([4, _ope | rest], acc),
    do: parse_instruction(rest, [{:bxc, nil} | acc])

  def parse_instruction([5, ope | rest], acc),
    do: parse_instruction(rest, [{:out, combo(ope)} | acc])

  def combo(4), do: {:combo, :A}
  def combo(5), do: {:combo, :B}
  def combo(6), do: {:combo, :C}
  def combo(v), do: {:lit, v}

  def parse(input) do
    [registers, program] = input |> String.trim() |> String.split("\n\n", trim: true)

    %{
      registers: parse_register(registers),
      program: parse_program(program),
      raw_program: raw_program(program),
      output: [],
      ip: 0
    }
  end

  ### Program Execution Functions
  def write_to(val, state, reg) do
    %{registers: r} = state
    Map.put(state, :registers, Map.put(r, reg, val))
  end

  def jump_to(state, destination), do: Map.put(state, :ip, destination)

  def move(state), do: Map.update(state, :ip, 0, &(&1 + 2))

  def output(state, val) do
    Map.update(state, :output, [], &[rem(val, 8) | &1])
  end

  def run_program(state) do
    %{registers: r, program: program, output: output, ip: ip} = state

    if program[ip] == nil do
      reverse(output)
    else
      {instruction, ope} = program[ip]

      dope =
        case ope do
          {:lit, v} -> v
          {:combo, reg} -> r[reg]
          nil -> nil
        end

      case instruction do
        :adv ->
          trunc(r[:A] / 2 ** dope) |> write_to(state, :A) |> move()

        :bdv ->
          trunc(r[:A] / 2 ** dope) |> write_to(state, :B) |> move()

        :cdv ->
          trunc(r[:A] / 2 ** dope) |> write_to(state, :C) |> move()

        :bxl ->
          Bitwise.bxor(r[:B], dope) |> write_to(state, :B) |> move()

        :bst ->
          rem(dope, 8) |> write_to(state, :B) |> move()

        :jnz ->
          if r[:A] != 0, do: jump_to(state, dope), else: move(state)

        :bxc ->
          Bitwise.bxor(r[:B], r[:C]) |> write_to(state, :B) |> move()

        :out ->
          output(state, dope) |> move()
      end
      |> run_program()
    end
  end

  def part1(args), do: args |> parse() |> run_program() |> join(",")

  ### Part 2
  def set_register(state, r, v) do
    Map.put(state, :registers, Map.put(state.registers, r, v))
  end

  def search(state, s, tail_size, target) do
    ## The key idea is to analyze the given program
    ## It is one loop. At each loop, the value of register A is divided by 8, so shift by 3 bits. At each loop, one value is outputted.
    ## The value computed at each loop depends on the value of register A
    ## The idea is to start from the **end** of the program and go backward, 3 bits at a time.
    max_int = 8 ** (length(target) + 1)

    if tail_size > length(target) do
      # We have found a solution
      div(s, 8)
    else
      # We consider the last `tail_size` elements of the output
      tail = slice(target, -tail_size, tail_size)

      # s: the current value of register A
      # We are going to consider the 8 possibilities for the last 3 bits of register A
      reduce(0..7, max_int, fn a, current_min ->
        res = state |> set_register(:A, s + a) |> run_program()

        if slice(res, -tail_size, tail_size) == tail do
          # Our program is a potential good candidate, as it finishes with the same values as the target
          # Then we continue the search, shifting the value of register A by 3 bits,in this hypothesis (a is a good candidate)
          s = search(state, (s + a) * 8, tail_size + 1, target)
          # We keep a running minimum
          if s < current_min, do: s, else: current_min
        else
          current_min
        end
      end)
    end
  end

  def part2(args) do
    state = args |> parse()
    result = search(state, 0, 1, state.raw_program)
    check_result = state |> set_register(:A, result) |> run_program()

    if check_result == state.raw_program,
      do: result,
      else: "No solution found"
  end
end
