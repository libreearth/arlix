defmodule ArlixTest do
  use ExUnit.Case
  doctest Arlix

  test "greets the world" do
    assert Arlix.hello() == :world
  end
end
