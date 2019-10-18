defmodule TitanikTest do
  use ExUnit.Case
  doctest Titanik

  test "greets the world" do
    assert Titanik.hello() == :world
  end
end
