defmodule AdventOfCode2021.Day11 do
  def puzzle1() do
    grid =
      for {line, row} <- AdventOfCode2021.get_input(11) |> Enum.with_index(),
          {num, col} <- String.to_charlist(line) |> Enum.with_index(),
          into: %{} do
        {{row, col}, num - ?0}
      end

    Enum.reduce(1..100, grid, fn _, gr ->
      plus_one =
        Enum.into(gr, %{}, fn
          {:flash_count, cnt} -> {:flash_count, cnt}
          {pt, num} -> {pt, num + 1}
        end)

      flash_queue =
        Enum.filter(plus_one, fn
          {:flash_count, _} -> false
          {_, num} -> num > 9
          _ -> false
        end)
        |> Enum.map(&elem(&1, 0))

      after_flash = chain_flashes(plus_one, flash_queue)

      flash_count =
        Enum.count(after_flash, fn
          {:flash_count, _} -> false
          {_, 0} -> true
          _ -> false
        end)

      Map.update(after_flash, :flash_count, flash_count, &(&1 + flash_count))
    end).flash_count
  end

  def puzzle2() do
    grid =
      for {line, row} <- AdventOfCode2021.get_input(11) |> Enum.with_index(),
          {num, col} <- String.to_charlist(line) |> Enum.with_index(),
          into: %{} do
        {{row, col}, num - ?0}
      end

    full_flash(grid)
  end

  def full_flash(grid, cycle \\ 1) do
    plus_one =
      Enum.into(grid, %{}, fn
        {pt, num} -> {pt, num + 1}
      end)

    flash_queue =
      Enum.filter(plus_one, fn
        {:flash_count, _} -> false
        {_, num} -> num > 9
        _ -> false
      end)
      |> Enum.map(&elem(&1, 0))

    after_flash = chain_flashes(plus_one, flash_queue)

    flash_count =
      Enum.count(after_flash, fn
        {_, 0} -> true
        _ -> false
      end)

    case flash_count == map_size(after_flash) do
      true -> cycle
      false -> full_flash(after_flash, cycle + 1)
    end
  end

  def chain_flashes(grid, queue)
  def chain_flashes(grid, []), do: grid

  def chain_flashes(grid, [point | queue]) do
    case grid[point] do
      0 ->
        chain_flashes(grid, queue)

      _ ->
        neighbours =
          for i <- -1..1,
              j <- -1..1,
              {row, col} = point,
              neigh = {row + i, col + j},
              neigh != point,
              grid[neigh] != nil,
              grid[neigh] != 0 do
            neigh
          end

        grid =
          Enum.reduce(neighbours, grid, fn pt, gr ->
            Map.update!(gr, pt, &(&1 + 1))
          end)
          |> Map.put(point, 0)

        chain_flashes(grid, queue ++ Enum.filter(neighbours, &(grid[&1] > 9)))
    end
  end
end
