defmodule AdventOfCodex2022.Day22 do
  def puzzle1() do
    input_to_board()
    |> follow_path(1)
    |> final_password()
  end

  def puzzle2() do
    input_to_board()
    |> follow_path(2)
    |> final_password()
  end

  defp input_to_board() do
    {map, [path]} =
      AdventOfCodex2022.read_input(22, trim: true)
      |> Enum.split(-1)

    %{
      path:
        path
        |> String.split(~r/((?<=[RL])|(?=[RL]))/, trim: true)
        |> Enum.map(fn
          "R" -> "R"
          "L" -> "L"
          int -> String.to_integer(int)
        end),
      map:
        map
        |> Enum.with_index(1)
        |> Map.new(fn {line, i} ->
          {i,
           line
           |> String.split("")
           |> Enum.drop(1)
           |> Enum.drop(-1)
           |> Enum.with_index(1)
           |> Enum.filter(fn
             {" ", _} -> false
             _ -> true
           end)
           |> Map.new(fn {v, j} -> {j, v} end)}
        end),
      dir: {0, 1}
    }
    |> initial_pos()
  end

  defp initial_pos(board = %{map: %{1 => first_row}}) do
    init_col = first_row |> Map.keys() |> Enum.min()
    board |> Map.put(:pos, {1, init_col}) |> Map.put(:host, {1, init_col})
  end

  defp follow_path(board, puzzle) do
    board.path
    |> Enum.reduce(board, fn
      "L", brd ->
        %{brd | dir: turn_left(brd.dir)}

      "R", brd ->
        %{brd | dir: turn_right(brd.dir)}

      dist, brd ->
        Enum.reduce_while(1..dist, brd, fn _, b ->
          {next_pos, next_dir} = {{nx, ny}, _} = get_map_next_pos_n_dir(b, puzzle)

          case b.map[nx][ny] do
            "#" -> {:halt, b}
            "." -> {:cont, %{b | pos: next_pos, dir: next_dir}}
          end
        end)
    end)
  end

  defp turn_left({x, y}), do: {-y, x}
  defp turn_right({x, y}), do: {y, -x}

  defp get_map_next_pos_n_dir(%{map: map, pos: {x, y}, dir: dir = {dx, dy}}, 1) do
    {case map[x + dx][y + dy] == nil do
       false ->
         {x + dx, y + dy}

       true ->
         case dx == 0 do
           true -> {x, y - dy * (map_size(map[x]) - 1)}
           false -> {x - dx * (length(for i <- Map.keys(map), map[i][y] != nil, do: i) - 1), y}
         end
     end, dir}
  end

  # Specific to the form of my own input 
  defp get_map_next_pos_n_dir(%{pos: {1, y}, dir: {-1, 0}}, 2) when 50 < y and y < 101,
    do: {{100 + y, 1}, {0, 1}}

  defp get_map_next_pos_n_dir(%{pos: {1, y}, dir: dir = {-1, 0}}, 2) when 100 < y,
    do: {{200, y - 100}, dir}

  defp get_map_next_pos_n_dir(%{pos: {101, y}, dir: {-1, 0}}, 2) when y < 51,
    do: {{50 + y, 51}, {0, 1}}

  defp get_map_next_pos_n_dir(%{pos: {x, 150}, dir: {0, 1}}, 2) when x < 51,
    do: {{151 - x, 100}, {0, -1}}

  defp get_map_next_pos_n_dir(%{pos: {x, 100}, dir: {0, 1}}, 2) when 50 < x and x < 101,
    do: {{50, x + 50}, {-1, 0}}

  defp get_map_next_pos_n_dir(%{pos: {x, 100}, dir: {0, 1}}, 2) when 100 < x,
    do: {{151 - x, 150}, {0, -1}}

  defp get_map_next_pos_n_dir(%{pos: {x, 50}, dir: {0, 1}}, 2) when 150 < x,
    do: {{150, x - 100}, {-1, 0}}

  defp get_map_next_pos_n_dir(%{pos: {200, y}, dir: dir = {1, 0}}, 2) when y < 51,
    do: {{1, 100 + y}, dir}

  defp get_map_next_pos_n_dir(%{pos: {150, y}, dir: {1, 0}}, 2) when 50 < y,
    do: {{100 + y, 50}, {0, -1}}

  defp get_map_next_pos_n_dir(%{pos: {50, y}, dir: {1, 0}}, 2) when 100 < y,
    do: {{y - 50, 100}, {0, -1}}

  defp get_map_next_pos_n_dir(%{pos: {x, 51}, dir: {0, -1}}, 2) when x < 51,
    do: {{151 - x, 1}, {0, 1}}

  defp get_map_next_pos_n_dir(%{pos: {x, 51}, dir: {0, -1}}, 2) when 50 < x and x < 101,
    do: {{101, x - 50}, {1, 0}}

  defp get_map_next_pos_n_dir(%{pos: {x, 1}, dir: {0, -1}}, 2) when x < 151,
    do: {{151 - x, 51}, {0, 1}}

  defp get_map_next_pos_n_dir(%{pos: {x, 1}, dir: {0, -1}}, 2) when 150 < x,
    do: {{1, x - 100}, {1, 0}}

  defp get_map_next_pos_n_dir(%{pos: {x, y}, dir: dir = {dx, dy}}, 2), do: {{x + dx, y + dy}, dir}

  defp final_password(%{pos: {x, y}, dir: dir}) do
    case dir do
      {0, 1} -> 0
      {1, 0} -> 1
      {0, -1} -> 2
      {-1, 0} -> 3
    end + 1000 * x + 4 * y
  end
end
