defmodule AdventOfCode2021.Day16 do
  @type parsed_packet :: %{
          :content => [parsed_packet] | number,
          :type_id => 0|1|2|3|4|5|6|7,
          :version => integer,
          optional(:sub_count) => integer,
          optional(:sub_size) => integer
        }

  @type soft_parsed_packet :: %{
          :content => [parsed_packet] | binary,
          :type_id => 0|1|2|3|4|5|6|7,
          :version => integer,
          optional(:sub_count) => integer,
          optional(:sub_size) => integer
        }

  @spec puzzle1 :: number
  def puzzle1 do
    get_parsed_input()
    |> version_sum()
  end

  @spec puzzle2 :: number
  def puzzle2 do
    get_parsed_input()
    |> value_of_packet()
  end

  @spec get_parsed_input :: parsed_packet
  def get_parsed_input do
    AdventOfCode2021.get_input(16)
    |> hd()
    |> hex_to_bin()
    |> parse_packet()
  end

  @spec version_sum(parsed_packet) :: number
  def version_sum(packet)
  def version_sum(%{version: ver, content: content}) when is_integer(content), do: ver

  def version_sum(%{version: ver, content: content}) when is_list(content) do
    (content |> Enum.map(&version_sum/1) |> Enum.sum()) + ver
  end

  @spec value_of_packet(parsed_packet) :: number
  def value_of_packet(packet)
  def value_of_packet(%{type_id: 0, content: content}), do: content |> Enum.map(&value_of_packet/1) |> Enum.sum
  def value_of_packet(%{type_id: 1, content: content}), do: content |> Enum.map(&value_of_packet/1) |> Enum.product()
  def value_of_packet(%{type_id: 2, content: content}), do: content |> Enum.map(&value_of_packet/1) |> Enum.min
  def value_of_packet(%{type_id: 3, content: content}), do: content |> Enum.map(&value_of_packet/1) |> Enum.max
  def value_of_packet(%{type_id: 4, content: content}), do: content
  def value_of_packet(%{type_id: 5, content: [p1, p2]}), do: if value_of_packet(p1) > value_of_packet(p2), do: 1, else: 0
  def value_of_packet(%{type_id: 6, content: [p1, p2]}), do: if value_of_packet(p1) < value_of_packet(p2), do: 1, else: 0
  def value_of_packet(%{type_id: 7, content: [p1, p2]}), do: if value_of_packet(p1) == value_of_packet(p2), do: 1, else: 0

  @spec hex_to_bin(binary) :: binary
  def hex_to_bin(hex) do
    with bin <- hex |> String.to_integer(16) |> Integer.to_string(2),
         len <- String.length(hex), do: String.pad_leading(bin, len * 4, ["0"])
  end

  def hex_to_bin_to_hex(hex) do
    hex |> hex_to_bin() |> String.to_integer(2) |> Integer.to_string(16)
  end

  @spec bin_to_int(binary) :: integer
  def bin_to_int(bin), do: String.to_integer(bin, 2)

  @spec parse_packet(binary) :: parsed_packet
  def parse_packet(packet) do
    case packet_soft_parsing(packet) do
      %{type_id: 4, content: content} = pkt ->
        %{pkt | content: parse_literal!(content)}

      %{sub_size: size, content: content} = pkt ->
        %{pkt | content: parse_packets_by_size!(content, size)}

      %{sub_count: count, content: content} = pkt ->
        %{pkt | content: parse_packets_by_count!(content, count)}
    end
  end

  @spec packet_soft_parsing(binary) :: soft_parsed_packet
  def packet_soft_parsing(packet) do
    <<ver::bytes-size(3)>> <> <<t_id::bytes-size(3)>> <> content = packet

    case t_id do
      "100" ->
        %{content: content}

      _ ->
        <<len_t_id::bytes-size(1)>> <> content = content

        case len_t_id do
          "0" ->
            <<sub_size::bytes-size(15)>> <> content = content
            %{content: content, sub_size: bin_to_int(sub_size)}

          "1" ->
            <<sub_count::bytes-size(11)>> <> content = content
            %{content: content, sub_count: bin_to_int(sub_count)}
        end
    end
    |> Map.merge(%{version: bin_to_int(ver), type_id: bin_to_int(t_id)})
  end

  @spec parse_literal!(binary) :: integer
  def parse_literal!(literal), do: parse_literal(literal) |> elem(0)

  @spec parse_literal(binary, binary) :: {integer, binary}
  def parse_literal(literal, parsed \\ "") do
    <<lead::bytes-size(1)>> <> <<value::bytes-size(4)>> <> rem = literal

    case lead do
      "0" -> {bin_to_int(parsed <> value), rem}
      "1" -> parse_literal(rem, parsed <> value)
    end
  end

  @spec parse_packets_by_size!(binary, non_neg_integer) :: [parsed_packet]
  def parse_packets_by_size!(packets, size), do: parse_packets_by_size(packets, size) |> elem(0)

  @spec parse_packets_by_size(binary(), non_neg_integer, [parsed_packet]) ::
          {[parsed_packet], binary}
  def parse_packets_by_size(packets, size, parsed \\ [])
  def parse_packets_by_size(rem, 0, parsed), do: {parsed, rem}

  def parse_packets_by_size(packets, size, parsed) do
    packet = packet_soft_parsing(packets)

    {content, rem} =
      case packet do
        %{type_id: 4, content: content} -> parse_literal(content)
        %{sub_size: size, content: content} -> parse_packets_by_size(content, size)
        %{sub_count: count, content: content} -> parse_packets_by_count(content, count)
      end

    rem_size = size - (String.length(packets) - String.length(rem))
    parse_packets_by_size(rem, rem_size, parsed ++ [%{packet | content: content}])
  end

  @spec parse_packets_by_count!(binary, non_neg_integer) :: [parsed_packet]
  def parse_packets_by_count!(packets, count),
    do: parse_packets_by_count(packets, count) |> elem(0)

  @spec parse_packets_by_count(binary(), non_neg_integer, [parsed_packet]) ::
          {[parsed_packet], binary}
  def parse_packets_by_count(packets, count, parsed \\ [])
  def parse_packets_by_count(rem, 0, parsed), do: {parsed, rem}

  def parse_packets_by_count(packets, count, parsed) do
    packet = packet_soft_parsing(packets)

    {content, rem} =
      case packet do
        %{type_id: 4, content: content} -> parse_literal(content)
        %{sub_size: size, content: content} -> parse_packets_by_size(content, size)
        %{sub_count: count, content: content} -> parse_packets_by_count(content, count)
      end

    parse_packets_by_count(rem, count - 1, parsed ++ [%{packet | content: content}])
  end
end
