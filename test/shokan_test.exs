defmodule ShokanTest do
  use ExUnit.Case
  doctest Shokan

  test "greets the world" do
    assert Shokan.hello() == :world
  end
end
