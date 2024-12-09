defmodule AdventOfCode.Day09 do
  import Enum

  def parse(args) do
    args |> to_charlist() |> map(&(&1 - ?0))
  end

  #### PART 1 ####
  def build_disk(blocks), do: build_disk(blocks, :file, {0, 0, [], []})

  def build_disk([], _, {m, _, free_map, file_map}) do
    disk = for(i <- 0..(m - 1), into: %{}, do: {i, :free}) |> Map.merge(Map.new(file_map))
    {reverse(free_map), file_map, disk}
  end

  def build_disk([n | r], :file, {block_id, file_id, free_map, file_map}) do
    new_file_map =
      reduce(block_id..(block_id + n - 1), file_map, fn i, acc -> [{i, file_id} | acc] end)

    build_disk(r, :free, {block_id + n, file_id + 1, free_map, new_file_map})
  end

  def build_disk([0 | r], :free, {block_id, file_id, free_map, file_map}) do
    build_disk(r, :file, {block_id, file_id, free_map, file_map})
  end

  def build_disk([n | r], :free, {block_id, file_id, free_map, file_map}) do
    new_free_map = reduce(block_id..(block_id + n - 1), free_map, fn i, acc -> [i | acc] end)
    build_disk(r, :file, {block_id + n, file_id, new_free_map, file_map})
  end

  def max_keys(a_map) do
    reduce(a_map, 0, fn {k, _}, acc -> Kernel.max(k, acc) end)
  end

  def rearrange({[], _file_map, disk}), do: disk
  def rearrange({_, [], disk}), do: disk

  def rearrange({[f | r_free], [fi | r_fi], disk}) do
    {last_file_block, file_id} = fi

    if f > last_file_block do
      disk
    else
      new_disk = Map.put(disk, f, file_id) |> Map.put(last_file_block, :free)
      rearrange({r_free, r_fi, new_disk})
    end
  end

  def checksum(disk) do
    for({block_id, file_id} <- disk, file_id != :free, do: block_id * file_id) |> sum()
  end

  def part1(args) do
    args |> parse() |> build_disk() |> rearrange() |> checksum()
  end

  #### PART 2 ####
  def build_disk2(blocks), do: build_disk2(blocks, :file, {0, 0, [], []})

  def build_disk2([], _, {_, _, free_zones, file_zones}), do: {reverse(free_zones), file_zones}

  def build_disk2([n | r], :file, {block_id, file_id, free_zones, file_zones}) do
    new_file_zones = [{block_id, n, file_id} | file_zones]
    build_disk2(r, :free, {block_id + n, file_id + 1, free_zones, new_file_zones})
  end

  def build_disk2([0 | r], :free, {block_id, file_id, free_zones, file_zones}) do
    build_disk2(r, :file, {block_id, file_id, free_zones, file_zones})
  end

  def build_disk2([n | r], :free, {block_id, file_id, free_zones, file_zones}) do
    new_free_zones = [{block_id, n} | free_zones]
    build_disk2(r, :file, {block_id + n, file_id, new_free_zones, file_zones})
  end

  def find_zone(free_zones, n, max_block_id) do
    reduce_while(free_zones, {false, 0}, fn {free_block_id, size}, {_, index} ->
      cond do
        free_block_id > max_block_id -> {:halt, {false, index}}
        size >= n -> {:halt, {true, index, free_block_id, size}}
        true -> {:cont, {false, index + 1}}
      end
    end)
  end

  def merge_adjacent_zones(l), do: merge_adjacent_zones(l, [])
  def merge_adjacent_zones([a], acc), do: [a | acc] |> reverse()

  def merge_adjacent_zones([{s1, n1}, {s2, n2} | r], acc) do
    if s1 + n1 == s2 do
      merge_adjacent_zones([{s1, n1 + n2} | r], acc)
    else
      merge_adjacent_zones([{s2, n2} | r], [{s1, n1} | acc])
    end
  end

  def rearrange2({free_zones, file_zones_to_move}),
    do: rearrange2(free_zones, file_zones_to_move, [])

  def rearrange2(free_zones, file_zones_to_move, processed_file_zones)

  def rearrange2(_free_zones, [], processed_file_zones) do
    processed_file_zones
  end

  def rearrange2(free_zones, [file_zone | r_fz], processed) do
    {block_id, file_size, file_id} = file_zone

    case find_zone(free_zones, file_size, block_id) do
      {false, _} ->
        rearrange2(free_zones, r_fz, [file_zone | processed])

      {true, free_zone_index, free_zone_block_id, free_zone_size} ->
        new_processed = [{free_zone_block_id, file_size, file_id} | processed]

        new_free_zones =
          if free_zone_size == file_size do
            [{block_id, file_size} | List.delete_at(free_zones, free_zone_index)]
          else
            [
              {block_id, file_size}
              | List.replace_at(
                  free_zones,
                  free_zone_index,
                  {free_zone_block_id + file_size, free_zone_size - file_size}
                )
            ]
          end
          |> sort()
          |> merge_adjacent_zones()

        rearrange2(new_free_zones, r_fz, new_processed)
    end
  end

  def checksum2(file_zones) do
    file_zones
    |> map(fn {block_id, file_size, file_id} ->
      for i <- block_id..(block_id + file_size - 1), do: i * file_id
    end)
    |> List.flatten()
    |> sum()
  end

  def part2(args) do
    args |> parse() |> build_disk2() |> rearrange2() |> checksum2()
  end
end
