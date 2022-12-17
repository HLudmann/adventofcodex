defmodule AdventOfCodex2022.Day2 do
  defmodule RPS do
    defstruct them: nil, me: nil, outcome: nil, score: nil
  end

  def puzzle1() do
    input_to_rps_p1()
    |> Enum.map(&compute_outcome/1)
    |> Enum.map(&compute_score/1)
    |> sum_scores
  end

  def puzzle2() do
    input_to_rps_p2()
    |> Enum.map(&compute_my_play/1)
    |> Enum.map(&compute_score/1)
    |> sum_scores
  end

  defp str_to_rps_attr_p1(str_play) do
    case str_play do
      "A" -> :rock
      "B" -> :paper
      "C" -> :scissor
      "X" -> :rock
      "Y" -> :paper
      "Z" -> :scissor
    end
  end

  @p1_translator %{"A" => :rock, "B" => :paper, "C" => :scissor}

  defp input_to_rps_p1() do
    AdventOfCodex2022.read_input(2, trim: true)
    |> Enum.map(fn line ->
      [them, me] = String.split(line, " ", trim: true) |> Enum.map(&str_to_rps_attr_p1/1)
      %__MODULE__.RPS{them: them, me: me}
    end)
  end

  defp str_to_rps_attr_p2(str_play) do
    case str_play do
      "A" -> :rock
      "B" -> :paper
      "C" -> :scissor
      "X" -> :lose
      "Y" -> :draw
      "Z" -> :win
    end
  end

  defp input_to_rps_p2() do
    AdventOfCodex2022.read_input(2, trim: true)
    |> Enum.map(fn line ->
      [them, outcome] = String.split(line, " ", trim: true) |> Enum.map(&str_to_rps_attr_p2/1)
      %__MODULE__.RPS{them: them, outcome: outcome}
    end)
  end

  defp compute_outcome(play = %__MODULE__.RPS{them: them, me: me}) do
    case {them, me} do
      {t, m} when t == m -> %{play | outcome: :draw}
      {:rock, :paper} -> %{play | outcome: :win}
      {:rock, :scissor} -> %{play | outcome: :lose}
      {:paper, :scissor} -> %{play | outcome: :win}
      {:paper, :rock} -> %{play | outcome: :lose}
      {:scissor, :rock} -> %{play | outcome: :win}
      {:scissor, :paper} -> %{play | outcome: :lose}
    end
  end

  @shape_pts [rock: 1, paper: 2, scissor: 3]
  @outcome_pts [win: 6, draw: 3, lose: 0]

  defp compute_score(play = %__MODULE__.RPS{outcome: outcome, me: me}),
    do: %{play | score: @outcome_pts[outcome] + @shape_pts[me]}

  defp sum_scores(plays) do
    plays |> Enum.map(fn %__MODULE__.RPS{score: score} -> score end) |> Enum.sum()
  end

  defp compute_my_play(play = %__MODULE__.RPS{them: them, outcome: outcome}) do
    case {them, outcome} do
      {_, :draw} -> %{play | me: them}
      {:rock, :win} -> %{play | me: :paper}
      {:paper, :win} -> %{play | me: :scissor}
      {:scissor, :win} -> %{play | me: :rock}
      {:rock, :lose} -> %{play | me: :scissor}
      {:paper, :lose} -> %{play | me: :rock}
      {:scissor, :lose} -> %{play | me: :paper}
    end
  end
end
