defmodule Test do

  def bar() do
    r0 = :rand.uniform(400)
    _ = :rand.seed(:exro928ss)
    r1 = :rand.uniform(400)
    receive do
      {:value, n} ->
        IO.puts("#{n} : #{r0}, #{r1}")
        bar()
      :quit -> :ok
    end
  end

  def bar_start(0, _) do :ok end
  def bar_start(n, pid) do
    send(pid, {:value, n})
    bar_start(n - 1, pid)
  end
  def bar_start() do
    pid = spawn(fn -> bar() end)
    bar_start(10,pid)
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
