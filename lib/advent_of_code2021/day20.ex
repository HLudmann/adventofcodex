defmodule AdventOfCode2021.Day20 do
  def puzzle1 do
    get_parsed_input()
    |> do_n_passes(2)
    |> Map.get(:grid)
    |> Enum.count(fn {_, val} -> val == 1 end)
  end

  def puzzle2 do
    get_parsed_input()
    |> do_n_passes(50)
    |> Map.get(:grid)
    |> Enum.count(fn {_, val} -> val == 1 end)
  end

  def get_parsed_input do
    [filter | image] = AdventOfCode2021.get_input(20)

    to_0_1 = fn
      46 -> 0
      35 -> 1
    end

    %{
      inf_pixel: 0,
      filt:
        filter
        |> String.to_charlist()
        |> Enum.map(&to_0_1.(&1))
        |> Enum.with_index()
        |> Enum.into(%{}, fn {v, k} -> {k, v} end),
      rows: length(image),
      cols: image |> hd |> String.length(),
      grid:
        image
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {line, row}, grid ->
          line
          |> String.to_charlist()
          |> Enum.with_index()
          |> Enum.into(%{}, fn {char, col} -> {{row, col}, to_0_1.(char)} end)
          |> Map.merge(grid)
        end)
    }
  end

  def do_n_passes(setup, 0), do: setup

  def do_n_passes(setup, n) do
    setup |> apply_filter() |> do_n_passes(n - 1)
  end

  def new_value(setup, point)

  def new_value(%{filt: filter, grid: grid, inf_pixel: inf_pixel}, {r, c}) do
    for l <- -1..1, m <- -1..1 do
      {r + l, c + m}
    end
    |> Enum.map(
      &case grid[&1] do
        nil -> inf_pixel
        b -> b
      end
    )
    |> Enum.join()
    |> String.to_integer(2)
    |> (fn val -> filter[val] end).()
  end

  def update_inf_pixel(%{filt: filter, inf_pixel: inf_pixel} = setup) do
    new =
      case inf_pixel do
        0 -> filter[0]
        1 -> filter[511]
      end

    Map.put(setup, :inf_pixel, new)
  end

  def apply_filter(%{rows: rows, cols: cols} = setup) do
    for r <- -1..rows, c <- -1..cols do
      {{r + 1, c + 1}, new_value(setup, {r, c})}
    end
    |> Enum.into(%{})
    |> (fn g -> Map.put(setup, :grid, g) end).()
    |> Map.update!(:rows, &(&1 + 2))
    |> Map.update!(:cols, &(&1 + 2))
    |> update_inf_pixel()
  end

  def print_grid(%{grid: grid, rows: rows, cols: cols} = setup) do
    for r <- 0..(rows - 1) do
      for c <- 0..(cols - 1) do
        case grid[{r, c}] do
          1 -> "#"
          0 -> "."
        end
      end
      |> Enum.join()
      |> IO.puts()
    end

    IO.puts("")
    setup
  end
end
