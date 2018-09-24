defmodule BubbleLib.MapUtil.AutoMapTest do
  use ExUnit.Case

  defmodule Location do
    defstruct [:lat, :lon]
  end

  alias BubbleLib.MapUtil.AutoMap

  test "put in" do
    assert %{"a" => %{"b" => 123}} == AutoMap.put_in(%{}, [:a, :b], 123)
    assert %{"a" => %{"b" => 123}} == AutoMap.put_in(%{"a" => 1}, [:a, :b], 123)
    assert %{"a" => %{"b" => 1, "c" => 2}} == AutoMap.put_in(%{"a" => %{"b" => 1}}, [:a, :c], 2)

    assert %{"a" => %{}} == AutoMap.put_in(%{"a" => %{"b" => 1}}, [:a], %{})
    assert %{"a" => %{"c" => 2}} == AutoMap.put_in(%{"a" => %{"b" => 1}}, [:a], %{"c" => 2})
    assert %{"payload" => "aap"} == AutoMap.put_in(%{"payload" => %{"x" => 2}}, [:payload], "aap")
  end

  test "put in w/ array" do
    assert %{"a" => []} == AutoMap.put_in(%{"a" => [1, 2, 3]}, [:a], [])

    assert %{"a" => [123]} == AutoMap.put_in(%{}, [:a, 0], 123)
    # generates an array
    assert %{"a" => [nil, nil, 123]} == AutoMap.put_in(%{}, [:a, 2], 123)

    # update existing array
    assert %{"a" => [123]} == AutoMap.put_in(%{"a" => [0]}, [:a, 0], 123)
    assert %{"a" => [10, 123]} == AutoMap.put_in(%{"a" => [10, 0]}, [:a, 1], 123)
    assert %{"a" => [10, 123, 11]} == AutoMap.put_in(%{"a" => [10, 0, 11]}, [:a, 1], 123)

    # extend existing array
    assert %{"a" => [0, nil, 123]} == AutoMap.put_in(%{"a" => [0]}, [:a, 2], 123)
    assert %{"a" => [0, nil, nil, nil, 123]} == AutoMap.put_in(%{"a" => [0]}, [:a, 4], 123)
  end

  test "get in" do
    assert nil == AutoMap.get_in(%{}, [:a, :b])
    assert 1 == AutoMap.get_in(%{"a" => 1}, [:a])
    assert 1 == AutoMap.get_in(%{"a" => 1}, ["a"])

    assert nil == AutoMap.get_in(%{"a" => 1}, ["a", "b"])
    assert nil == AutoMap.get_in(%{"a" => 1}, ["a", :b])

    assert %{"b" => 1} == AutoMap.get_in(%{"a" => %{"b" => 1}}, ["a"])
  end

  test "get_in traverses structs" do
    assert 1 == AutoMap.get_in(%{"a" => %Location{lat: 1}}, ["a", "lat"])
    assert 1 == AutoMap.get_in(%{"a" => %Location{lat: 1}}, ["a", :lat])
    assert nil == AutoMap.get_in(%{"a" => %Location{lat: 1}}, ["a", :lat, :x])
  end

  test "get in traverses lists" do
    assert 1 == AutoMap.get_in(%{"a" => [1]}, [:a, 0])
    assert 123 == AutoMap.get_in(%{"a" => [1, 123]}, [:a, 1])

    assert nil == AutoMap.get_in(%{}, [:a, 0])
    assert nil == AutoMap.get_in(%{"a" => [1, 123]}, [:a, 100])
    assert nil == AutoMap.get_in(%{"a" => [1, 123]}, [:a, :foo])
  end

  test "get in w/ negative index" do
    assert 1 == AutoMap.get_in(%{"a" => [1]}, [:a, -1])
    assert 2 == AutoMap.get_in(%{"a" => [1, 2]}, [:a, -1])
    assert 2 == AutoMap.get_in(%{"a" => [1, 2, 3]}, [:a, -2])
  end

  test "remove" do
    assert %{"a" => %{"y" => 2}} == AutoMap.remove(%{"a" => %{"x" => 1, "y" => 2}}, ["a", "x"])
    assert %{"a" => [nil, 1]} == AutoMap.remove(%{"a" => [111, 1]}, ["a", 0])
  end

  test "remove collapse - map" do
    assert %{} == AutoMap.remove(%{"a" => %{"x" => 1}}, ["a", "x"])
    assert %{} == AutoMap.remove(%{"a" => %{"x" => %{"y" => 1}}}, ["a", "x"])
    assert %{} == AutoMap.remove(%{"a" => %{"x" => %{"y" => 1}}}, ["a", "x", "y"])
  end

  test "remove collapse - list" do
    assert %{} == AutoMap.remove(%{"a" => [1]}, ["a", 0])
    assert %{} == AutoMap.remove(%{"a" => %{"b" => [1]}}, ["a", "b", 0])
    assert %{2 => 3} == AutoMap.remove(%{"a" => %{"b" => [1]}, 2 => 3}, ["a", "b", 0])
  end

  test "get in - filter" do
    data = %{"foo" => [%{"a" => 1}, %{"a" => 2}]}
    assert [%{"a" => 1}] = AutoMap.get_in(data, ["foo", [a: 1]])
  end

  test "iterate" do
    values = [1, 2, 3]
    value = AutoMap.loop_start(values)
    assert {:next, 1, value} = AutoMap.loop_next(value)
    assert {:next, 2, value} = AutoMap.loop_next(value)
    assert {:next, 3, value} = AutoMap.loop_next(value)
    assert :stop = AutoMap.loop_next(value)
  end
end