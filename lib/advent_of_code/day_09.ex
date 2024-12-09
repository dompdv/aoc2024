defmodule AdventOfCode.Day09 do
  import Enum

  def add(m, key, val) do
    case Map.fetch(m, key) do
      {:ok, l} -> Map.put(m, key, [val | l])
      :error -> Map.put(m, key, [val])
    end
  end

  def build_disk([], _, {m, _, free_map, file_map}) do
    disk = for(i <- 0..(m - 1), into: %{}, do: {i, :free}) |> Map.merge(file_map)
    {reverse(free_map), file_map, disk}
  end

  def build_disk([n | r], :file, {block_id, file_id, free_map, file_map}) do
    new_file_map =
      reduce(block_id..(block_id + n - 1), file_map, fn i, acc -> Map.put(acc, i, file_id) end)

    build_disk(r, :free, {block_id + n, file_id + 1, free_map, new_file_map})
  end

  def build_disk([n | r], :free, {block_id, file_id, free_map, file_map}) do
    new_free_map = reduce(block_id..(block_id + n - 1), free_map, fn i, acc -> [i | acc] end)
    build_disk(r, :file, {block_id + n, file_id, new_free_map, file_map})
  end

  def max_keys(a_map) do
    reduce(a_map, 0, fn {k, _}, acc -> Kernel.max(k, acc) end)
  end

  def rearrange({[], _file_map, disk}), do: disk

  def rearrange({[f | r], file_map, disk}) do
    last_file_block = max_keys(file_map)

    if f > last_file_block do
      disk
    else
      file_id = Map.get(file_map, last_file_block)
      new_file_map = file_map |> Map.delete(last_file_block) |> Map.put(f, file_id)
      new_disk = Map.put(disk, f, file_id) |> Map.put(last_file_block, :free)
      rearrange({r, new_file_map, new_disk})
    end
  end

  def checksum(disk) do
    reduce(disk, 0, fn
      {_, :free}, acc -> acc
      {block_id, file_id}, acc -> acc + block_id * file_id
    end)
  end

  def parse(args) do
    args |> to_charlist() |> map(&(&1 - ?0)) |> build_disk(:file, {0, 0, [], %{}})
  end

  def part1(args) do
    args |> parse() |> rearrange() |> checksum()
  end

  def part2(args) do
    args
  end

  def test(_) do
    "2333133121414131402"
  end
end
