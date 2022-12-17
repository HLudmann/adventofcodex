defmodule AdventOfCodex2022.Day11 do
  defmodule Monkey do
    defstruct [:id, :items, :op, :num, :test, :if_true, :if_false]
  end

  defmodule Item do
    defstruct [:id, :val, views: %{}]
  end

  def puzzle1() do
    monkeys = input_to_monkeys()
    limiter_fn = &div(&1, 3)

    monkeys
    |> Enum.map(&Map.get(&1 |> elem(1), :items))
    |> List.flatten()
    |> Enum.map(fn item -> item |> cycle_item_n_times(20, monkeys, limiter_fn) end)
    |> sum_views()
    |> prod_of_two_maxes()
  end

  def puzzle2() do
    monkeys = input_to_monkeys()

    limiter_fn = fn val ->
      rem(val, monkeys |> Enum.map(fn {_k, m} -> m.test end) |> Enum.product())
    end

    monkeys
    |> Enum.map(&Map.get(&1 |> elem(1), :items))
    |> List.flatten()
    |> Enum.map(fn item -> item |> cycle_item_n_times(10_000, monkeys, limiter_fn) end)
    |> sum_views()
    |> prod_of_two_maxes()
  end

  @monkey_regex ~r/^Monkey (?<id>\d+):-  Starting items: (?<items>[\w,\s]+)-  Operation: new = old (?<op>[\*\+]) (?<num>(\d+|old))-  Test: divisible by (?<test>\d+)-    If true: throw to monkey (?<if_true>\d+)-    If false: throw to monkey (?<if_false>\d+)$/

  defp input_to_monkeys() do
    AdventOfCodex2022.read_input(11, trim: true)
    |> Enum.chunk_every(6)
    |> Enum.map(fn chunk ->
      Regex.named_captures(@monkey_regex, chunk |> Enum.join("-"))
      |> Enum.into(%{}, fn
        {"num", "old"} ->
          {:num, "old"}

        {"op", op} ->
          {:op, op}

        {"items", items} ->
          {"items",
           items
           |> String.split(", ", trim: true)
           |> Enum.map(fn item -> item |> String.to_integer() end)}

        {k, v} ->
          {k |> String.to_existing_atom(), v |> String.to_integer()}
      end)
      |> Map.pop!("items")
      |> (fn {items, map = %{id: id}} ->
            Monkey |> struct(map |> Map.put(:items, items |> Enum.map(&%Item{id: id, val: &1})))
          end).()
    end)
    |> Enum.into(%{}, &{&1.id, &1})
  end

  defp cycle_item_n_times(item, n, monkeys, limiter_fn)
  defp cycle_item_n_times(item, 0, _, _), do: item

  defp cycle_item_n_times(item = %Item{id: id, val: val, views: views}, n, monkeys, limiter_fn) do
    new_val =
      case monkeys[id] do
        %Monkey{num: "old"} -> val * val
        %Monkey{op: "*", num: num} -> val * num
        %Monkey{op: "+", num: num} -> val + num
      end
      |> limiter_fn.()

    %Monkey{test: tval, if_true: ift, if_false: iff} = monkeys[id]
    next = (rem(new_val, tval) == 0 && ift) || iff
    n = (next > id && n) || n - 1

    %{item | val: new_val, id: next, views: views |> Map.update(id, 1, &(&1 + 1))}
    |> cycle_item_n_times(n, monkeys, limiter_fn)
  end

  defp sum_views(items) do
    items |> Enum.reduce(%{}, &Map.merge(&2, &1.views, fn _k, v1, v2 -> v1 + v2 end))
  end

  defp prod_of_two_maxes(views) do
    views |> Enum.map(&elem(&1, 1)) |> Enum.sort(:desc) |> Enum.take(2) |> Enum.product()
  end
end
