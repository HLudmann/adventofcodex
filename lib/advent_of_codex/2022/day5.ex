defmodule AdventOfCodex2022.Day5 do
  @containers_init %{
    1 => 'NTBSQHGR',
    2 => 'JZPDFSH',
    3 => 'VHZ',
    4 => 'HGFJZM',
    5 => 'RSMLDCZT',
    6 => 'JZHVWTM',
    7 => 'ZLPFT',
    8 => 'SWVQ',
    9 => 'CNDTMLHW'
  }
  @move_regex ~r/^move (?<size>\d+) from (?<src>\d+) to (?<dest>\d+)$/
  def puzzle1() do
    input_to_moves()
    |> Enum.reduce(@containers_init, &move_creates/2)
    |> get_message()
  end

  def puzzle2() do
    input_to_moves()
    |> Enum.reduce(@containers_init, &new_move_crates/2)
    |> get_message()
  end

  defp input_to_moves() do
    AdventOfCodex2022.read_input(5, trim: true)
    |> Enum.map(&Regex.named_captures(@move_regex, &1))
    |> Enum.map(&Enum.into(&1, %{}, fn {k, v} -> {k, String.to_integer(v)} end))
  end

  defp move_creates(containers, move, new_model \\ false)

  defp move_creates(
         %{"size" => size, "src" => src, "dest" => dest},
         containers,
         new_model
       ) do
    {moving, staying} = Enum.split(containers[src], size)

    new_dest_c =
      case new_model do
        true -> moving
        _ -> Enum.reverse(moving)
      end ++ containers[dest]

    %{containers | src => staying, dest => new_dest_c}
  end

  defp new_move_crates(containers, move), do: move_creates(containers, move, true)

  defp get_message(containers), do: Enum.map(containers, fn {_, v} -> Enum.at(v, 0) end)
end
