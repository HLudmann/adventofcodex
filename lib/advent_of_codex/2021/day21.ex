defmodule AdventOfCodex2021.Day21 do
  def puzzle1 do
    Stream.cycle(1..100)
    |> Stream.chunk_every(3)
    |> Enum.reduce_while(get_parsed_input() |> to_board(), fn rolls, board ->
      case play(board, Enum.sum(rolls)) do
        %{score1: score} = b when score >= 1000 -> {:halt, b}
        %{score2: score} = b when score >= 1000 -> {:halt, b}
        b -> {:cont, b}
      end
    end)
    |> (fn
          %{score1: s1, score2: s2, rolls: r} when s1 >= 1000 -> s2 * r
          %{score1: s1, score2: s2, rolls: r} when s2 >= 1000 -> s1 * r
        end).()
  end

  def puzzle2 do
    get_parsed_input()
    |> to_quantum_boards()
    |> quantum_play()
    |> (fn %{w1: w1, w2: w2} -> max(w1, w2) end).()
  end

  def get_parsed_input do
    AdventOfCodex2021.get_input(21)
    |> Enum.map(fn line ->
      ~r/^Player \d starting position: (?<pos>\d+)$/
      |> Regex.named_captures(line)
      |> Map.get("pos")
      |> String.to_integer()
    end)
  end

  def to_board([player1, player2]),
    do: %{pos1: player1 - 1, score1: 0, pos2: player2 - 1, score2: 0, rolls: 0}

  def to_quantum_boards([player1, player2]) do
    %{b: %{to_board([player1, player2]) => 1}, w1: 0, w2: 0}
  end

  def play(board, move)

  def play(%{pos1: pos, score1: score, rolls: r} = board, move) when rem(r, 6) == 0 do
    new_pos = rem(pos + move, 10)

    %{board | pos1: new_pos, score1: score + new_pos + 1, rolls: r + 3}
  end

  def play(%{pos2: pos, score2: score, rolls: r} = board, move) do
    new_pos = rem(pos + move, 10)

    %{board | pos2: new_pos, score2: score + new_pos + 1, rolls: r + 3}
  end

  @rolls %{3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}

  def quantum_play(quantum_boards)
  def quantum_play(%{b: boards} = quantum_boards) when map_size(boards) == 0, do: quantum_boards

  def quantum_play(%{b: boards, w1: pw1, w2: pw2} = quantum_boards) do
    Enum.reduce(boards, {%{}, 0, 0}, fn {board, cnt}, {new_boards, wins1, wins2} ->
      Enum.reduce(@rolls, {new_boards, wins1, wins2}, fn {move, nbr}, {new_bs, w1, w2} ->
        new_val = cnt * nbr

        case play(board, move) do
          %{score1: s} when s >= 21 -> {new_bs, w1 + new_val, w2}
          %{score2: s} when s >= 21 -> {new_bs, w1, w2 + new_val}
          b -> {Map.update(new_bs, b, new_val, &(&1 + new_val)), w1, w2}
        end
      end)
    end)
    |> (fn {boards, wins1, wins2} ->
          %{quantum_boards | b: boards, w1: pw1 + wins1, w2: pw2 + wins2}
        end).()
    |> quantum_play()
  end
end
