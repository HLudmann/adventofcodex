defmodule AdventOfCodex2022.Day23 do
  defmodule Elf do
    defstruct pos: nil, next: nil
  end

  def puzzle1() do
    input_to_elfs()
    |> process(10)
    |> elem(0)
    |> count_empty()
  end

  def puzzle2() do
    input_to_elfs()
    |> process(100_000)
    |> elem(1)
  end

  defp input_to_elfs() do
    AdventOfCodex2022.read_input(23, trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> (&for(
          i <- 0..(length(&1) - 1),
          j <- 0..(length(Enum.at(&1, 0)) - 1),
          &1 |> Enum.at(i) |> Enum.at(j) == "#",
          into: %{},
          do: {{i, j}, %Elf{pos: {i, j}}}
        )).()
  end

  defp process(
         elf_map,
         max_round,
         cur_round \\ 1,
         checks \\ [&north?/2, &south?/2, &west?/2, &east?/2]
       )

  defp process(elf_map, max_round, cur_round, _) when max_round < cur_round,
    do: {elf_map, max_round}

  defp process(elf_map, max_round, cur_round, checks = [h | t]) do
    case elf_map |> plan(checks) |> move() do
      ^elf_map -> {elf_map, cur_round}
      new_map -> new_map |> process(max_round, cur_round + 1, t ++ [h])
    end
  end

  defp count_empty(elf_map) do
    {x_range, y_range} = smallest_rectangle(elf_map)
    for(x <- x_range, y <- y_range, elf_map[{x, y}] == nil, do: 1) |> Enum.sum()
  end

  defp print(elf_map, msg) do
    {x_range, y_range} = smallest_rectangle(elf_map)

    IO.puts(msg)

    for x <- x_range do
      for(y <- y_range, do: (elf_map[{x, y}] && "#") || ".") |> Enum.join("") |> IO.puts()
    end
  end

  defp smallest_rectangle(elf_map) do
    x_range =
      elf_map
      |> Map.keys()
      |> Enum.map(&elem(&1, 0))
      |> Enum.min_max()
      |> (fn {mn, mx} -> mn..mx end).()

    y_range =
      elf_map
      |> Map.keys()
      |> Enum.map(&elem(&1, 1))
      |> Enum.min_max()
      |> (fn {mn, mx} -> mn..mx end).()

    {x_range, y_range}
  end

  defp north?(elfs, %Elf{pos: {x, y}}) do
    case Enum.all?(-1..1, &(elfs[{x - 1, y + &1}] == nil)) do
      true -> {x - 1, y}
      false -> nil
    end
  end

  defp south?(elfs, %Elf{pos: {x, y}}) do
    case Enum.all?(-1..1, &(elfs[{x + 1, y + &1}] == nil)) do
      true -> {x + 1, y}
      false -> nil
    end
  end

  defp east?(elfs, %Elf{pos: {x, y}}) do
    case Enum.all?(-1..1, &(elfs[{x + &1, y + 1}] == nil)) do
      true -> {x, y + 1}
      false -> nil
    end
  end

  defp west?(elfs, %Elf{pos: {x, y}}) do
    case Enum.all?(-1..1, &(elfs[{x + &1, y - 1}] == nil)) do
      true -> {x, y - 1}
      false -> nil
    end
  end

  defp alone?(elfs, %Elf{pos: pos = {x, y}}) do
    (for dx <- -1..1, dy <- -1..1, pos != {x + dx, y + dy}, elfs[{x + dx, y + dy}] != nil do
       :ko
     end
     |> Enum.empty?() && pos) || nil
  end

  defp plan(elfs, checks) do
    elfs
    |> Map.values()
    |> Enum.map(fn elf ->
      Enum.reduce_while([(&alone?/2) | checks], elf, fn check, e ->
        case check.(elfs, e) do
          nil -> {:cont, e}
          next_pos -> {:halt, %{e | next: next_pos}}
        end
      end)
    end)
    |> Enum.group_by(fn elf -> elf.next end)
  end

  defp move(next_map) do
    next_map
    |> Enum.reduce(%{}, fn
      {pos, [elf]}, elf_map when pos != nil ->
        Map.put(elf_map, pos, %{elf | pos: pos, next: nil})

      {_, elfs}, elf_map ->
        Map.merge(elf_map, for(e <- elfs, into: %{}, do: {e.pos, %{e | next: nil}}))
    end)
  end
end
