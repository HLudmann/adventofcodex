defmodule AdventOfCode2021.Day19 do
  def puzzle1 do
    spt = get_parsed_input()

    scan_pt_to_s0 =
      spt
      |> scanners_coordinates_and_reoriontation()
      |> point_to_s0()

    Enum.reduce(spt, [], fn {scan, pts}, pts_in_s0 ->
      func = scan_pt_to_s0[scan]
      pts_in_s0 ++ Enum.map(pts, &func.(&1))
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def puzzle2 do
    get_parsed_input()
    |> scanners_coordinates_and_reoriontation()
    |> Enum.map(fn {_, {pt, _}} -> pt end)
    |> (fn points -> combinations(2, points) end).()
    |> Enum.map(fn [p1, p2] -> diff(p1, p2) |> Enum.map(&abs/1) |> Enum.sum() end)
    |> Enum.max()
  end

  defp get_parsed_input do
    AdventOfCode2021.get_input(19)
    |> Enum.reduce({%{}, nil}, fn line, {pts_map, scan} ->
      case Regex.named_captures(~r/--- scanner (?<scan>\d+) ---/, line) do
        %{"scan" => s} ->
          {pts_map, String.to_integer(s)}

        _ ->
          point = String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
          {Map.update(pts_map, scan, [point], &(&1 ++ [point])), scan}
      end
    end)
    |> elem(0)
  end

  defp scanners_coordinates_and_reoriontation(scan_pts) do
    scan_pts
    |> Enum.into(%{}, fn {scan, pts} -> {scan, triangles(pts)} end)
    |> scanner_matching_pairs()
    |> order()
    |> Enum.reduce(
      %{0 => {[0, 0, 0], fn pt -> pt end}},
      fn [
           s1,
           s2,
           [{pt11, pt21}, {pt12, pt22}, _]
         ],
         scr ->
        {s1_0, s1_reor} = scr[s1]
        [pt11, pt12] = Enum.map([pt11, pt12], &s1_reor.(&1))

        s2_reor = diff(pt11, pt12) |> axis_reorientation(diff(pt21, pt22))
        s2_1 = s1_0 |> add(pt11) |> diff(s2_reor.(pt21))

        Map.put(scr, s2, {s2_1, s2_reor})
      end
    )
  end

  defp point_to_s0(scan_coor_reor) do
    Enum.into(scan_coor_reor, %{}, fn {scan, {coor, reor}} ->
      {scan, fn pt -> reor.(pt) |> add(coor) end}
    end)
  end

  defp triangles(points) do
    for [p1, p2, p3] <- combinations(3, points) do
      [p1, p2, p3]
    end
    |> Enum.into(%{}, fn [p1, p2, p3] = pts ->
      d = [dist_square(p1, p2), dist_square(p1, p3), dist_square(p2, p3)] |> Enum.sort()
      {d, pts}
    end)
  end

  defp scanner_matching_pairs(scan_tri) do
    for [s1, s2] <- combinations(2, Map.keys(scan_tri)) do
      [s1, s2, matching_distances(scan_tri[s1], scan_tri[s2])]
    end
    # 12 choose 3 = 220
    |> Enum.filter(fn [_, _, matches] -> length(matches) >= 220 end)
    |> Enum.map(fn [s1, s2, [first | _]] ->
      [s1, s2, match_pts_by_dist(scan_tri[s1][first], scan_tri[s2][first])]
    end)
  end

  defp matching_distances(tri_a, tri_b) do
    keys1 = Map.keys(tri_a) |> MapSet.new()
    keys2 = Map.keys(tri_b) |> MapSet.new()

    MapSet.intersection(keys1, keys2) |> MapSet.to_list()
  end

  defp match_pts_by_dist([p11, p12, p13], [p21, p22, p23]) do
    [a, b, c] = [dist_square(p11, p12), dist_square(p11, p13), dist_square(p12, p13)]
    d2 = [dist_square(p21, p22), dist_square(p21, p23), dist_square(p22, p23)]

    case d2 do
      [^a, ^b, ^c] -> [{p11, p21}, {p12, p22}, {p13, p23}]
      [^a, ^c, ^b] -> [{p11, p22}, {p12, p21}, {p13, p23}]
      [^b, ^a, ^c] -> [{p11, p21}, {p12, p23}, {p13, p22}]
      [^c, ^b, ^a] -> [{p11, p23}, {p12, p22}, {p13, p21}]
      [^b, ^c, ^a] -> [{p11, p22}, {p12, p23}, {p13, p21}]
      [^c, ^a, ^b] -> [{p11, p23}, {p12, p21}, {p13, p22}]
    end
  end

  defp order(matches, base \\ [0])
  defp order([], _), do: []

  defp order(matches, base) do
    {from_base, rem} = Enum.split_with(matches, fn [s, _, _] -> s in base end)
    {to_base, rem} = Enum.split_with(rem, fn [_, s, _] -> s in base end)

    with_base =
      from_base ++
        Enum.map(to_base, fn [s1, s2, [{p11, p21}, {p12, p22}, {p13, p23}]] ->
          [s2, s1, [{p21, p11}, {p22, p12}, {p23, p13}]]
        end)

    with_base ++ order(rem, Enum.map(with_base, fn [_, s, _] -> s end))
  end

  defp combinations(size, set)
  defp combinations(0, _), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(n, [h | t]) do
    for c <- combinations(n - 1, t) do
      [h | c]
    end ++ combinations(n, t)
  end

  defp dist_square([x1, y1, z1], [x2, y2, z2]) do
    (:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2) + :math.pow(z1 - z2, 2)) |> round()
  end

  defp add(point_a, point_b)
  defp add([x1, y1, z1], [x2, y2, z2]), do: [x1 + x2, y1 + y2, z1 + z2]

  defp diff(point_a, point_b)
  defp diff([x1, y1, z1], [x2, y2, z2]), do: [x1 - x2, y1 - y2, z1 - z2]

  defp axis_permutation(diff_scan_a, diff_scan_b) do
    [dx, dy, dz] = Enum.map(diff_scan_a, &abs/1)

    case Enum.map(diff_scan_b, &abs/1) do
      [^dx, ^dy, ^dz] -> fn pt -> pt end
      [^dx, ^dz, ^dy] -> fn [x, z, y] -> [x, y, z] end
      [^dy, ^dx, ^dz] -> fn [y, x, z] -> [x, y, z] end
      [^dy, ^dz, ^dx] -> fn [y, z, x] -> [x, y, z] end
      [^dz, ^dx, ^dy] -> fn [z, x, y] -> [x, y, z] end
      [^dz, ^dy, ^dx] -> fn [z, y, x] -> [x, y, z] end
    end
  end

  defp axis_reorientation(diff_scan_a, diff_scan_b) do
    perm = axis_permutation(diff_scan_a, diff_scan_b)

    flip =
      case perm.(diff_scan_b) |> diff(diff_scan_a) do
        [0, 0, 0] -> fn pt -> pt end
        [0, 0, _] -> fn [x, y, z] -> [x, y, -z] end
        [0, _, 0] -> fn [x, y, z] -> [x, -y, z] end
        [_, 0, 0] -> fn [x, y, z] -> [-x, y, z] end
        [0, _, _] -> fn [x, y, z] -> [x, -y, -z] end
        [_, 0, _] -> fn [x, y, z] -> [-x, y, -z] end
        [_, _, 0] -> fn [x, y, z] -> [-x, -y, z] end
        _ -> fn [x, y, z] -> [-x, -y, -z] end
      end

    fn pt -> perm.(pt) |> flip.() end
  end
end
