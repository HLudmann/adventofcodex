defmodule AdventOfCode2021.Day18 do
  def puzzle1, do: get_parsed_input() |> compute_pairs() |> magnitude()

  def puzzle2, do: get_parsed_input() |> biggest_addition()

  def get_parsed_input do
    AdventOfCode2021.get_input(18)
    |> Enum.map(&Code.string_to_quoted!/1)
    |> Enum.map(&parse_pair/1)
  end

  def magnitude(pair)
  def magnitude(val) when is_integer(val), do: val
  def magnitude(%{l: left, r: right}), do: 3 * magnitude(left) + 2 * magnitude(right)

  def compute_pairs([first | rem]) do
    Enum.reduce(rem, first, fn right, left -> add_pairs(left, right) |> reduce() end)
  end

  def biggest_addition(pairs) do
    for left <- pairs, right <- pairs, left != right do
      add_pairs(left, right) |> reduce() |> magnitude()
    end
    |> Enum.max()
  end

  def parse_pair(pair) when is_integer(pair), do: pair
  def parse_pair([left, right]), do: %{l: parse_pair(left), r: parse_pair(right)}

  def add_pairs(left, right), do: %{l: left, r: right}

  def reduce(pair) do
    cond do
      (path = four_nested_path(pair)) != nil -> explode(pair, path) |> reduce()
      (path = ten_value_path(pair)) != nil -> split(pair, path) |> reduce()
      true -> pair
    end
  end

  def explode(pair, path) do
    %{l: l, r: r} = get_in(pair, path)
    l_neigh = left_neighbour(pair, path)
    r_neigh = right_neighbour(pair, path)

    pair
    |> update_in(path, fn _ -> 0 end)
    |> update_node(l_neigh, l)
    |> update_node(r_neigh, r)
  end

  def split(pair, path) do
    half = get_in(pair, path) / 2
    put_in(pair, path, %{l: floor(half), r: ceil(half)})
  end

  def update_node(pair, nil, _), do: pair
  def update_node(pair, path, add), do: update_in(pair, path, &(&1 + add))

  def ten_value_path(pair, path \\ [])
  def ten_value_path(val, _) when is_integer(val) and val < 10, do: nil
  def ten_value_path(val, path) when is_integer(val), do: path

  def ten_value_path(%{l: l, r: r}, path) do
    case ten_value_path(l, path ++ [:l]) do
      nil -> ten_value_path(r, path ++ [:r])
      p -> p
    end
  end

  def four_nested_path(pair, path \\ [])
  def four_nested_path(%{}, path) when length(path) == 4, do: path
  def four_nested_path(_, path) when length(path) == 4, do: nil

  def four_nested_path(%{l: l, r: r}, path) do
    case four_nested_path(l, path ++ [:l]) do
      nil -> four_nested_path(r, path ++ [:r])
      p -> p
    end
  end

  def four_nested_path(_, _), do: nil

  def left_neighbour(pair, path)
  def left_neighbour(_, [:l, :l, :l, :l]), do: nil

  def left_neighbour(pair, [p1, p2, p3, p4]) do
    cond do
      p4 == :r -> [p1, p2, p3, :l]
      p3 == :r -> go_right(pair, [p1, p2, :l])
      p2 == :r -> go_right(pair, [p1, :l])
      true -> go_right(pair, [:l])
    end
  end

  def right_neighbour(pair, path)
  def right_neighbour(_, [:r, :r, :r, :r]), do: nil

  def right_neighbour(pair, [p1, p2, p3, p4]) do
    cond do
      p4 == :l -> go_left(pair, [p1, p2, p3, :r])
      p3 == :l -> go_left(pair, [p1, p2, :r])
      p2 == :l -> go_left(pair, [p1, :r])
      true -> go_left(pair, [:r])
    end
  end

  def go_right(pair, path) do
    case get_in(pair, path) do
      %{} -> go_right(pair, path ++ [:r])
      _ -> path
    end
  end

  def go_left(pair, path) do
    case get_in(pair, path) do
      %{} -> go_left(pair, path ++ [:l])
      _ -> path
    end
  end
end
