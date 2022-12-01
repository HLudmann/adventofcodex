defmodule AdventOfCode2021.Day12 do
  def puzzle1() do
    get_parsed_input()
    |> build_paths(&small_cave_rule_p1?/2)
    |> MapSet.size()
  end

  def puzzle2 do
    get_parsed_input()
    |> build_paths(&small_cave_rule_p2?/2)
    |> MapSet.size()
  end

  def small_cave_rule_p1?(cave, path), do: cave in path

  def small_cave_rule_p2?(cave, path) do
    case small_cave_rule_p1?(cave, path) do
      false ->
        false

      true ->
        small_caves = Enum.filter(path, &(String.downcase(&1) == &1))
        Enum.uniq(small_caves) != small_caves
    end
  end

  def get_parsed_input do
    AdventOfCode2021.get_input(12)
    |> Enum.reduce(%{}, fn link, m ->
      [pt_a, pt_b] = String.split(link, "-")
      m |> Map.update(pt_a, [pt_b], &[pt_b | &1]) |> Map.update(pt_b, [pt_a], &[pt_a | &1])
    end)
  end

  @spec build_paths(
          %{String.t() => [String.t()]},
          (String.t(), [String.t()] -> boolean),
          MapSet.t(String.t())
        ) :: MapSet.t(String.t())
  def build_paths(map, small_cave_rule, paths \\ MapSet.new())

  def build_paths(map, small_cave_rule, %MapSet{map: map_set}) when map_size(map_set) == 0 do
    build_paths(map, small_cave_rule, MapSet.new([["start"]]))
  end

  def build_paths(map, small_cave_rule, paths) do
    updated_paths =
      Enum.reduce(paths, %MapSet{}, fn
        ["end" | _] = path, new_paths ->
          MapSet.put(new_paths, path)

        [cave | _] = path, new_paths ->
          Enum.reduce(map[cave], %MapSet{}, fn
            "start", cave_paths ->
              cave_paths

            neigh, cave_paths ->
              case String.downcase(neigh) == neigh and small_cave_rule.(neigh, path) do
                true -> cave_paths
                false -> MapSet.put(cave_paths, [neigh | path])
              end
          end)
          |> MapSet.union(new_paths)
      end)

    case Enum.all?(updated_paths, &(hd(&1) == "end")) do
      true -> updated_paths
      false -> build_paths(map, small_cave_rule, updated_paths)
    end
  end
end
