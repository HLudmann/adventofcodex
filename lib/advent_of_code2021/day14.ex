defmodule AdventOfCode2021.Day14 do
  def puzzle1() do
    Enum.reduce(1..10, get_parsed_input(), fn _, chain_n_rules ->
      division(chain_n_rules)
    end)
    |> elements_count()
    |> min_max_diff()
  end

  def puzzle2() do
    Enum.reduce(1..40, get_parsed_input(), fn _, chain_n_rules ->
      division(chain_n_rules)
    end)
    |> elements_count()
    |> min_max_diff()
  end

  def get_parsed_input() do
    AdventOfCode2021.get_input(14)
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.group_by(
      fn
        [_template] -> :template
        _ -> :rules
      end,
      fn
        [template] ->
          String.to_charlist(template)

        [pair, elem] ->
          [left, right] = charlist_pair = String.to_charlist(pair)
          charlist_elem = String.to_charlist(elem)
          {charlist_pair, [[left | charlist_elem], charlist_elem ++ [right]]}
      end
    )
    |> Map.update!(:rules, &Enum.into(&1, %{}))
    |> Map.update!(:template, &Enum.at(&1, 0))
    |> molecules_count()
  end

  def molecules_count(%{template: temp} = temp_n_rules) do
    Map.put(
      temp_n_rules,
      :molecules_count,
      temp |> Enum.chunk_every(2, 1, :discard) |> Enum.frequencies()
    )
  end

  def division(%{rules: rules, molecules_count: mols_cnt} = temp_rules_n_count) do
    new_mols_cnt =
      Enum.reduce(mols_cnt, %{}, fn {mol, cnt}, mols_cnt_acc ->
        [mol1, mol2] = rules[mol]

        mols_cnt_acc
        |> Map.update(mol1, cnt, &(&1 + cnt))
        |> Map.update(mol2, cnt, &(&1 + cnt))
      end)

    Map.put(temp_rules_n_count, :molecules_count, new_mols_cnt)
  end

  def elements_count(%{template: [first | _], molecules_count: mols_cnt}) do
    Enum.reduce(mols_cnt, %{}, fn {[_, elem], cnt}, elems_cnt ->
      Map.update(elems_cnt, elem, cnt, &(&1 + cnt))
    end)
    |> Map.update(first, 1, &(&1 + 1))
  end

  def min_max_diff(elements_count) do
    {min, max} = Enum.map(elements_count, &elem(&1, 1)) |> Enum.min_max()

    max - min
  end
end
