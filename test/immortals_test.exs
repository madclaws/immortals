defmodule ImmortalsTest do
  use ExUnit.Case
  doctest Immortals

  test "greets the world" do
    assert Immortals.hello() == :world
  end
end
