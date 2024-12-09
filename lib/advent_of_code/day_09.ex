defmodule AdventOfCode.Day09 do
  import Enum

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
    reduce(disk, 0, fn
      {_, :free}, acc -> acc
      {block_id, file_id}, acc -> acc + block_id * file_id
    end)
  end

  def parse(args) do
    args |> to_charlist() |> map(&(&1 - ?0))
  end

  def part1(args) do
    args |> parse() |> build_disk(:file, {0, 0, [], []}) |> rearrange() |> checksum()
  end

  def part2(args) do
    args
  end

  def test(_) do
    "1023"
  end
end
