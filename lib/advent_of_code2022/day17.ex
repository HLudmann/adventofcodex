defmodule AdventOfCode2022.Day17 do
  defmodule Board do
    defstruct shape: nil, form: nil, grid: %{}, height: 0, count: 0, history: [], buffer: ""
  end

  def puzzle1(), do: tetris(2022)

  def puzzle2(), do: tetris(1_000_000_000_000)

  defp tetris(stop) do
    dirs = input_to_dirs()
    dirs_len = length(dirs)

    test_hist = fn hist ->
      hist |> length() |> rem(5) == 0 and
        hist |> Enum.map(&(&1 |> elem(1) |> String.length())) |> Enum.sum() > dirs_len
    end

    dirs
    |> Stream.cycle()
    |> Enum.reduce_while(
      %Board{} |> line_shape(),
      fn
        _, board = %{count: ^stop} ->
          {:halt, board}

        dir, board ->
          case board |> go_sideways(dir) |> go_down() do
            {:ok, b} ->
              {:cont, b}

            {:ko, b} ->
              new_b =
                %Board{history: hist, count: cnt, height: h} =
                b |> add_shape_to_grid() |> next_shape()

              case (test_hist.(hist) && find_pattern(hist)) || :ko do
                :ko ->
                  {:cont, new_b}

                {:ok, pat} ->
                  pat_len = length(pat)
                  pat_incr = pat |> Enum.map(&elem(&1, 2))
                  full_cycles_incr = div(stop - cnt, pat_len) * (pat_incr |> Enum.sum())
                  last_cycle_bit_incr = pat |> Enum.take(rem(stop - cnt, pat_len)) |> Enum.sum()

                  {:cont,
                   %{new_b | count: stop, height: h + full_cycles_incr + last_cycle_bit_incr}}
              end
          end
      end
    )
    |> Map.get(:height)
  end

  defp input_to_dirs() do
    AdventOfCode2022.read_input(17, trim: true) |> Enum.at(0) |> String.split("", trim: true)
  end

  def print(board = %Board{grid: grid, height: h}) do
    (for(
       y <- (h + 1)..0,
       do: "|" <> (Enum.map(0..6, &((grid[{&1, y}] == 1 && "#") || ".")) |> Enum.join("")) <> "|"
     ) ++ ["+-------+"])
    |> Enum.join("\n")
    |> IO.puts()

    board
  end

  defp go_right(board = %Board{shape: shape, grid: grid, buffer: b}) do
    case shape |> Enum.count(fn {x, y} -> x == 6 or grid[{x + 1, y}] != nil end) == 0 do
      false -> board
      true -> %{board | buffer: b <> ">", shape: shape |> Enum.map(fn {x, y} -> {x + 1, y} end)}
    end
  end

  defp go_left(board = %Board{shape: shape, grid: grid, buffer: b}) do
    case shape |> Enum.count(fn {x, y} -> x == 0 or grid[{x - 1, y}] != nil end) == 0 do
      false -> board
      true -> %{board | buffer: b <> "<", shape: shape |> Enum.map(fn {x, y} -> {x - 1, y} end)}
    end
  end

  defp go_sideways(board, "<"), do: go_left(board)
  defp go_sideways(board, ">"), do: go_right(board)

  defp go_down(board = %{shape: shape, grid: grid}) do
    case shape |> Enum.count(fn {x, y} -> y == 1 or grid[{x, y - 1}] != nil end) == 0 do
      false -> {:ko, board}
      true -> {:ok, %{board | shape: shape |> Enum.map(fn {x, y} -> {x, y - 1} end)}}
    end
  end

  defp high_point(points), do: points |> Enum.max(&(elem(&1, 1) >= elem(&2, 1))) |> elem(1)

  defp add_shape_to_grid(
         board = %{
           shape: shape,
           form: f,
           grid: grid,
           count: c,
           height: h,
           history: hist,
           buffer: b
         }
       ) do
    new_h = max(h, high_point(shape))

    %{
      board
      | count: c + 1,
        grid: shape |> Enum.reduce(grid, &Map.put(&2, &1, 1)),
        height: new_h,
        history: hist ++ [{f, b, new_h - h}],
        buffer: ""
    }
  end

  defp find_pattern([]), do: :ko
  defp find_pattern([_]), do: :ko

  defp find_pattern(hist = [_ | rest]) do
    case Enum.split(hist, hist |> length() |> div(2)) do
      {p, p} -> {:ok, p}
      _ -> find_pattern(rest)
    end
  end

  defp next_shape(board = %Board{form: :line}), do: plus_shape(board)
  defp next_shape(board = %Board{form: :plus}), do: l_shape(board)
  defp next_shape(board = %Board{form: :l}), do: i_shape(board)
  defp next_shape(board = %Board{form: :i}), do: square_shape(board)
  defp next_shape(board = %Board{form: :square}), do: line_shape(board)

  defp line_shape(board = %Board{height: h}) do
    %{board | form: :line, shape: [{2, h + 4}, {3, h + 4}, {4, h + 4}, {5, h + 4}]}
  end

  defp plus_shape(board = %Board{height: h}) do
    %{board | form: :plus, shape: [{3, h + 4}, {2, h + 5}, {3, h + 5}, {4, h + 5}, {3, h + 6}]}
  end

  defp l_shape(board = %Board{height: h}) do
    %{board | form: :l, shape: [{2, h + 4}, {3, h + 4}, {4, h + 4}, {4, h + 5}, {4, h + 6}]}
  end

  defp i_shape(board = %Board{height: h}) do
    %{board | form: :i, shape: [{2, h + 4}, {2, h + 5}, {2, h + 6}, {2, h + 7}]}
  end

  defp square_shape(board = %Board{height: h}) do
    %{board | form: :square, shape: [{2, h + 4}, {3, h + 4}, {2, h + 5}, {3, h + 5}]}
  end
end
