defmodule Schedule.Util do
  def deep_atomize(map) when is_map(map), do: Enum.reduce(map, %{}, &put_atomized/2)

  def deep_atomize(list) when is_list(list), do: Enum.map(list, &maybe_deep_atomize/1)

  def maybe_deep_atomize(map_or_list) when is_map(map_or_list) or is_list(map_or_list),
    do: deep_atomize(map_or_list)

  def maybe_deep_atomize(value), do: value

  def put_atomized({key, value}, map) do
    Map.put(map, atomize(key), maybe_deep_atomize(value))
  end

  def atomize(string) when is_binary(string), do: String.to_atom(string)
  def atomize(atom) when is_atom(atom), do: atom
end
