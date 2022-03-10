defmodule Dinner do
  def bench(n) do
    if File.exists?("data_w_20_500.txt") do File.rm("data_w_20_500.txt") end
    {:ok, file} = File.open("data_w_20_500.txt", [:read, :utf8, :write,])
    hunger = Enum.to_list(1..n)
    Enum.map(hunger, fn(h) -> bench(h, file) end)
    :done
  end

  def bench(h, file) do
    {time, _} = :timer.tc(fn -> init(h) end)
    ms = round(time / 1000)
    IO.binwrite(file, "#{h}\t#{ms}\t#{round(ms/h)}\n")
  end

  def start(), do: spawn(fn -> init(10) end)
  def init(n) do
    c1 = Chopstick.start()
    c2 = Chopstick.start()
    c3 = Chopstick.start()
    c4 = Chopstick.start()
    c5 = Chopstick.start()
    ctrl = self()
    waiter = spawn(fn -> waiter(0) end)
    Philosopher.start(n, c2, c1, "Arendt", ctrl, waiter)
    Philosopher.start(n, c3, c2, "Hypatia", ctrl, waiter)
    Philosopher.start(n, c4, c3, "Simone", ctrl, waiter)
    Philosopher.start(n, c5, c4, "Elisabeth", ctrl, waiter)
    Philosopher.start(n, c1, c5, "Ayn", ctrl, waiter)
    wait(5, [c1, c2, c3, c4, c5])
  end
  def wait(0, chopsticks) do
    #IO.puts("quitting")
    Enum.each(chopsticks, fn(c) -> Chopstick.quit(c) end)
  end
  def wait(n, chopsticks) do
    receive do
    :done ->
      #IO.puts("#{n - 1} Philosophers left")
      wait(n - 1, chopsticks)
    :abort ->
      #IO.puts("Aborting")
      Process.exit(self(), :kill)
    end
  end

  def waiter(n) do
    receive do
      {:hungry, from} ->
        if n < 4 do
          send(from, :ok)
          waiter(n + 1)
        else
          send(from, :wait)
          waiter(n)
        end
      :done ->
        waiter(n - 1)
    end
  end

end
defmodule Philosopher do
  #dream state
  def dream(0,_,_,name, ctrl,_) do
    #IO.puts("#{name} is finished.")
    send(ctrl, :done)
  end

  def dream(hunger, left, right, name, ctrl, waiter) do
    #IO.puts("#{name} is dreaming.")
    sleep(500)
    #IO.puts("#{name} is awaken.")
    request(hunger, left, right, name, ctrl, waiter)
  end

  #request state
  def request(hunger, left, right, name, ctrl, waiter) do
    send(waiter, {:hungry, self()})
    #IO.puts("#{name} waits to be served.")
    receive do
      :ok ->
        #IO.puts("#{name} is allowed to fetch her sticks.")
        case Chopstick.request(left, right) do
          :ok ->
            #IO.puts("#{name} got her chopsticks.")
            eat(hunger, left, right, name, ctrl, waiter)
        end
      :wait ->
        #IO.puts("#{name} has to wait to eat.")
        request(hunger, left, right, name, ctrl, waiter)
    end

  end

  # eat state
  def eat(hunger, left_c, right_c, name, ctrl, waiter) do
    #IO.puts("#{name} is eating. Hunger is #{hunger}.")

    sleep(20)

    Chopstick.return(left_c)
    #IO.puts("#{name} returned her left chopstick.")
    Chopstick.return(right_c)
    #IO.puts("#{name} returned her right chopstick.")
    send(waiter, :done)
    dream(hunger - 1, left_c, right_c, name, ctrl, waiter)
  end

  def start(hunger, left_c, right_c, name, ctrl, waiter) do
    spawn_link(fn -> dream(hunger, left_c, right_c, name, ctrl, waiter) end)

  end



  def sleep(0) do :ok end
  def sleep(t) do
    t = :rand.uniform(t)
    #IO.puts("random nr: #{t}")
    :timer.sleep(t)
  end

end


defmodule Chopstick do
  def quit({:chopstick, stick}) do
    send(stick, :quit)
  end

  def request({:chopstick, left}, {:chopstick, right}) do
    send(left, {:request, self()})
    send(right, {:request, self()})
    receive do
      :granted ->
        receive do
          :granted ->
            :ok
        end
    end

  end


  def return({:chopstick, stick}) do
    send(stick, :return)
  end

  def start() do
    {:chopstick, spawn_link(fn -> available() end)}
  end

  def available() do
    receive do
      {:request, from} ->
        send(from, :granted)
        gone()
      :quit -> :ok
    end
  end

  def gone() do
    receive do
      :return ->
        available()
      :quit -> :ok
    end
  end

end
