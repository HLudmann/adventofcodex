defmodule AdventOfCode2022.Day16 do
  import Bitwise

  def puzzle1() do
    input_to_valves()
    |> visit("AA", 30, 0, 0, %{})
    |> Map.values()
    |> Enum.max()
  end

  def puzzle2() do
    input_to_valves()
    |> visit("AA", 26, 0, 0, %{})
    |> (&for({s1, v1} <- &1, {s2, v2} <- &1, s1 != s2, do: v1 + v2)).()
    |> Enum.max()
  end

  defp input_to_valves() do
    AdventOfCode2022.read_input(16, trim: true)
    |> Enum.map(fn line ->
      ~r/^Valve (?<name>[A-Z]{2}) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<neigh>.+)$/
      |> Regex.named_captures(line)
    end)
    |> Enum.reduce(
      %{neighs: %{}, useful: %{}, states: %{}, dists: %{}},
      fn %{
           "name" => name,
           "rate" => rate,
           "neigh" => neigh
         },
         valves = %{
           neighs: neighs,
           useful: useful,
           states: states
         } ->
        rate = String.to_integer(rate)
        neigh = String.split(neigh, ", ", trim: true)

        %{
          valves
          | neighs: Map.put(neighs, name, neigh),
            useful: (rate == 0 && useful) || Map.put(useful, name, rate),
            states: (rate == 0 && states) || Map.put(states, name, 1 <<< map_size(states))
        }
      end
    )
    |> compute_dists()
  end

  defp compute_dists(valves = %{neighs: neighs}) do
    v_names = Map.keys(neighs)
    nbs = &neighs[&1]
    dist = h = fn _, _ -> 1 end

    :ets.new(:dists, [:named_table])

    dists =
      for src <- v_names, into: %{} do
        {src,
         for dest <- v_names, into: %{} do
           dist =
             case :ets.lookup(:dists, {src, dest}) do
               [{_, value}] ->
                 value |> IO.inspect(label: "from")

               _ ->
                 path = [src | Astar.astar({nbs, dist, h}, src, dest)]

                 for s <- path,
                     d <- path,
                     si = Enum.find_index(path, & &1==s),
                     di = Enum.find_index(path, & &1==d),
                     do: :ets.insert(:dists, {{d, s}, Range.size(si..di) - 1})

                 (length(path) - 1)|>IO.inspect(label: "to")
             end

           {dest, dist}
         end}
      end

    :ets.delete(:dists)
    %{valves | dists: dists}
  end

  defp visit(
         valves = %{useful: useful, dists: dists, states: states},
         valve,
         max_time,
         state,
         steam_flow,
         result
       ) do
    result = result |> Map.put(state, result |> Map.get(state, 0) |> max(steam_flow))

    useful
    |> Map.keys()
    |> Enum.reduce(result, fn dest, res ->
      rem_time = max_time - dists[valve][dest] - 1

      case (states[dest] &&& state) >= 1 or rem_time <= 0 do
        true ->
          res

        false ->
          visit(
            valves,
            dest,
            rem_time,
            state ||| states[dest],
            steam_flow + rem_time * useful[dest],
            res
          )
      end
    end)
  end
end
