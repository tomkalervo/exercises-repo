defmodule Test do

  def bar() do
    r0 = :rand.uniform(40)
    r1 = :rand.uniform(40)
    receive do
      :value ->
        IO.puts("#{{r0,r1}}")
        bar()
      :quit -> :ok
    end
  end

  def foo(name) do
    receive do
      {:count, value} ->
        IO.puts("#{name} has count #{value}")
        :timer.sleep(:rand.uniform(2000))
        foo(name)
      :quit ->
        IO.puts("#{name} is done")
        :ok
    end
  end

  def start() do
    one = spawn_link(fn -> foo("One") end)
    two = spawn_link(fn -> foo("Two") end)
    countdown(10, one, two)
  end

  def countdown(0, one, two) do
    send(one, :quit)
    send(two, :quit)
  end
  def countdown(n, one, two) do
    send(one, {:count, n})
    send(two, {:count, n})
    countdown(n - 1, one, two)
  end

  def echo() do
    receive do
      {:echo, value} ->
        IO.puts("#{value}")
      :quit -> :ok
    end

  end

end
