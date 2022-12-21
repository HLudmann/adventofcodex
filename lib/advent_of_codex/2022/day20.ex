defmodule AdventOfCodex2022.Day20 do
  def puzzle1() do
    input_to_nums()
    |> move()
    |> move_first_zero_to_start()
    |> sum_at([1_000, 2_000, 3_000])
  end

  def puzzle2() do
    input_to_nums()
    |> move(10, 811_589_153)
    |> move_first_zero_to_start()
    |> sum_at([1_000, 2_000, 3_000])
  end

  defp move_first_zero_to_start(enum) do
    case Enum.split_while(enum, &(&1 != 0)) do
      {[], rest} -> rest
      {right, left} -> left ++ right
    end
  end

  defp sum_at(enum, indexes) do
    len = length(enum)

    indexes
    |> Enum.map(fn index -> Enum.at(enum, rem(index, len)) end)
    |> Enum.sum()
  end

  defp input_to_nums(),
    do: AdventOfCodex2022.read_input(20, trim: true) |> Enum.map(&String.to_integer/1)

  defp move(numbers, runs \\ 1, key \\ 1) do
    order = numbers |> Enum.map(&(&1 * key)) |> Enum.with_index()
    num_to_ind = Map.new(order, fn x = {_, i} -> {x, i} end)
    ind_to_num = Map.new(order, fn x = {_, i} -> {i, x} end)

    run({num_to_ind, ind_to_num}, order, runs)
    |> elem(1)
    |> Enum.sort_by(fn {i, _} -> i end)
    |> Enum.map(fn {_, {v, _}} -> v end)
  end

  defp run(maps, _, 0), do: maps

  defp run(maps, order, runs_left) do
    mod = length(order) - 1

    order
    |> Enum.reduce(maps, fn
      {v, i}, acc when rem(v, mod) == 0 ->
        ProgressBar.render(i + 1, mod + 1, suffix: :count)
        acc

      x = {val, i}, {n2i, i2n} ->
        v = rem(val, mod)
        cur_i = n2i[x]

        nex_i =
          cond do
            cur_i + v <= 0 -> cur_i + v + mod
            cur_i + v > mod -> cur_i + v - mod
            true -> cur_i + v
          end

        update_positions({n2i, i2n}, x, cur_i, nex_i)
        |> tap(fn _ -> ProgressBar.render(i + 1, mod + 1, suffix: :count) end)
    end)
    |> run(order, runs_left - 1)
  end

  defp update_positions(pos, _, same, same), do: pos

  defp update_positions({n2i, i2n}, x, cur, nex) do
    {mv, rg} =
      case cur < nex do
        true -> {-1, (cur + 1)..nex}
        false -> {1, nex..(cur - 1)}
      end

    len = map_size(n2i)

    {n2i_up, i2n_up} =
      Enum.reduce(rg, {%{x => nex}, %{nex => x}}, fn ind, {niu, inu} ->
        ind = rem(ind + len, len)
        nid = rem(ind + len + mv, len)
        {niu |> Map.put(i2n[ind], nid), inu |> Map.put(nid, i2n[ind])}
      end)

    {n2i |> Map.merge(n2i_up), i2n |> Map.merge(i2n_up)}
  end
end
