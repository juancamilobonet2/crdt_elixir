defmodule Treedoc do

  # posid will be {bitstring, disambiguator}
  # tree will be like %{left: tree|nil, right: tree|nil, value: [{disambiguator,msg, tombstoned}, ...]}


  def new do
    %{left: nil, right: nil, value: []}
  end

  def insert(tree, value, {[], disambiguator}) do
    %{tree | value: [{disambiguator, value, false} | tree[:value]]}
  end
  def insert(tree, value, {[hd | tl], disambiguator}) do
    if hd == 0 do
      case tree[:left] do
        nil ->
          new_tree = insert(new(), value, {tl, disambiguator})
          %{tree | left: new_tree}
        _ ->
          new_tree = insert(tree[:left], value, {tl, disambiguator})
          %{tree | left: new_tree}
      end
    else
      case tree[:right] do
        nil ->
          new_tree = insert(new(), value, {tl, disambiguator})
          %{tree | right: new_tree}
        _ ->
          new_tree = insert(tree[:right], value, {tl, disambiguator})
          %{tree | right: new_tree}
      end
    end
  end

  def lookup(tree, {[], dis}) do
    # might be nil
    msgs = tree[:value]
    Enum.find(msgs, fn {disam, _, _} -> disam==dis end)
  end
  def lookup(tree, {[hd|tl], disambiguator}) do
    if hd == 0 do
      lookup(tree[:left], {tl, disambiguator})
    else
      lookup(tree[:right], {tl, disambiguator})
    end
  end

  def delete(tree, posid) do
    #TODO
  end

  def generate_msg_posid(tree, disambiguator, posid) do
    #TODO tree balancing mentioned in 4.1
    # we want the message to be in the position most to the right
    # in order walk
    cond do
      tree[:value] == []  and !right_tree_full?(tree[:right]) ->
        generate_msg_posid(tree[:left],disambiguator, posid ++ [0])
      tree[:value] == []  and right_tree_full?(tree[:right]) ->
        posid ++ [disambiguator]
      tree[:value] != [] and tree[:right] != nil ->
        generate_msg_posid(tree[:right],disambiguator, posid ++ [1])
      tree[:value] != [] and tree[:right] == nil ->
        #here should be 4.1
        posid ++ [1] ++ [disambiguator]
    end
  end

  def right_tree_full?(tree) do
    cond do
      tree[:value] == [] ->
        false
      tree[:right] == nil ->
        true
      true ->
        right_tree_full?(tree[:right])
    end
  end

  def compare_posid({posid1, dis1}, {posid2, dis2}) do
    less = compare_posid_bitstring(posid1, posid2)
    if less do
      true
    else
      greater = compare_posid_bitstring(posid2, posid1)
      if greater do
        false
      else
        compare_disambiguator(dis1, dis2)
      end

    end
  end

  # returns true if posid1 is strictly less than posid2
  def compare_posid_bitstring([], []), do: false
  def compare_posid_bitstring([], [hd|_tl]), do: hd == 1
  def compare_posid_bitstring([hd|_tl], []), do: hd == 0
  def compare_posid_bitstring([hd1 | tl1], [hd2 | tl2]) do
    if hd1 == hd2 do
      compare_posid_bitstring(tl1, tl2)
    else
      hd1 < hd2
    end
  end

  def compare_disambiguator(dis1, dis2) do
    #TODO depends on how disambiguators are defined
    true
  end
end
