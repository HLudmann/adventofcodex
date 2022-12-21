defmodule AdventOfCodex2022.Day21 do
  def puzzle1() do
    input_to_map()
    |> get_value()
  end

  def puzzle2() do
    input_to_map()
    |> find_humn_value()
  end

  defp input_to_map() do
    AdventOfCodex2022.read_input(21, trim: true)
    |> Enum.reduce(%{}, fn line, map ->
      case String.split(line, ~r'[^\d\w\+\-\*/]+', trim: true) do
        [name, value] ->
          Map.put(map, name, value |> String.to_integer())

        [name, left, operation, right] ->
          Map.put(map, name, {operation, left, right})
      end
    end)
  end

  defp get_value(map, key \\ "root") do
    cache = :ets.new(:cached21, [:set, :named_table])

    get_value(map, key, cache)
    |> tap(fn _ -> :ets.delete(cache) end)
  end

  defp get_value(map, key, cache) do
    case :ets.lookup(cache, key) do
      [{_, value}] ->
        value

      _ ->
        case map[key] do
          {operation, left, right} ->
            to_function(operation).(get_value(map, left, cache), get_value(map, right, cache))

          value ->
            value
        end
        |> tap(fn val -> :ets.insert(cache, {key, val}) end)
    end
  end

  defp to_function(operation)
  defp to_function("+"), do: &+/2
  defp to_function("-"), do: &-/2
  defp to_function("*"), do: &*/2
  defp to_function("/"), do: &div/2

  defp find_humn_value(map) do
    humn_cache = :ets.new(:cached21p2h, [:set, :named_table])
    value_cache = :ets.new(:cached21p2v, [:set, :named_table])

    {_, left, right} = map["root"]

    {value, key} =
      case {use_humn(map, left, humn_cache), use_humn(map, right, humn_cache)} do
        {true, false} -> {get_value(map, right, value_cache), left}
        {false, true} -> {get_value(map, left, value_cache), right}
      end

    find_humn_value(map, value, key, value_cache, humn_cache)
    |> tap(fn _ -> {:ets.delete(humn_cache), :ets.delete(value_cache)} end)
  end

  defp find_humn_value(_, value, "humn", _, _), do: value

  defp find_humn_value(map, value, key, vcache, hcache) do
    {operation, left, right} = map[key]

    {value, key} =
      case {use_humn(map, left, hcache), use_humn(map, right, hcache)} do
        {true, false} ->
          {to_inverse(operation).(value, get_value(map, right, vcache)), left}

        {false, true} ->
          {case operation do
             "/" -> div(get_value(map, left, vcache), value)
             "-" -> get_value(map, left, vcache) - value
             _ -> to_inverse(operation).(value, get_value(map, left, vcache))
           end, right}
      end

    find_humn_value(map, value, key, vcache, hcache)
  end

  defp use_humn(_, "humn", _), do: true

  defp use_humn(map, key, cache) do
    case :ets.lookup(cache, key) do
      [{_, value}] ->
        value

      _ ->
        case map[key] do
          {_, "humn", _} -> true
          {_, _, "humn"} -> true
          {_, left, right} -> use_humn(map, left, cache) or use_humn(map, right, cache)
          _ -> false
        end
        |> tap(fn value -> :ets.insert(cache, {key, value}) end)
    end
  end

  defp to_inverse("+"), do: &-/2
  defp to_inverse("-"), do: &+/2
  defp to_inverse("*"), do: &div/2
  defp to_inverse("/"), do: &*/2
end
