defmodule Bench do

  def bench(n) do
    {ctrl, _} = :timer.tc(fn -> :timer.sleep(1000) end)
    {tseq, _} = :timer.tc(fn() -> loop(fn -> Mandel.demo() end, n) end)
    {taseq, _} = :timer.tc(fn() -> loop(fn -> Mandel_p.demo() end, n) end)

    ts = div(tseq, n)
    ta = div(taseq, n)
    ts = div(ts, 1_000)
    ta = div(ta, 1_000)

    IO.write("Sync: \t#{ts} ms\nAsync: \t#{ta} ms\nCtrl: \t#{ctrl}\n")
  end

  def loop(_,0), do: :ok
  def loop(fun, n) do
    fun.()
    loop(fun, n - 1)
  end
end

defmodule Mandel_p do
  def demo() do
    small(-2.6, 0.7, 1.2)
    :ok
  end
  def small(x0, y0, xn) do
    width = 960
    height = 240
    depth = 64
    k = (xn - x0) / width
    me = self()
    print = spawn_link(fn -> PPM.write_p("small1.ppm", width, height, me) end)
    color = spawn_link(fn -> color(depth, print) end)
    Mandel_p.mandelbrot(width, height, x0, y0, k, depth, color)
    wait()
  end

  def wait() do
    receive do
      :done ->
        :ok
    end
  end


  def mandelbrot(width, height, x, y, k, depth, ref) do
    trans = fn(w, h) ->
      Cmplx.new(x + k * (w - 1), y - k * (h - 1))
      end
    rows(width, 1, height + 1, trans, depth, ref)
  end

  def color(depth, ref) do
    receive do
      :done ->
        send(ref, :done)
      lst ->
        row = Enum.map(lst, fn(e)-> Color.convert(e, depth) end)
        send(ref, row)
        color(depth, ref)
    end
  end

  def rows(_, h, h, _, _, ref), do: send(ref, :done)
  def rows(w, h, height, trans, depth, ref) do
    row = build_row(w, h, trans, depth, [])
    send(ref, row)
    rows(w, h + 1, height, trans, depth, ref)
  end

  def build_row(0, _, _, _, row), do: row
  def build_row(width, h, trans, depth, row) do
    pixel = trans.(width, h)
    {:set, i} = Brot.mandelbrot(pixel, depth)
    build_row(width - 1, h, trans, depth, [i|row])
  end
end

defmodule Mandel do
  def demo() do
      small(-2.6, 1.2, 1.2)
      :ok
  end
  def small(x0, y0, xn) do
    width = 960
    height = 540
    depth = 64
    k = (xn - x0) / width
    image = Mandel.mandelbrot(width, height, x0, y0, k, depth)
    PPM.write("smaller.ppm", image)
  end


  def mandelbrot(width, height, x, y, k, depth) do
    trans = fn(w, h) ->
      Cmplx.new(x + k * (w - 1), y - k * (h - 1))
      end
    rows(width, height, trans, depth, [])
  end

  def rows(_, 0, _, _, rows), do: rows
  def rows(w, height, trans, depth, rows) do
    rows = [build_row(w, height, trans, depth, []) | rows]
    rows(w, height - 1, trans, depth, rows)
  end

  def build_row(0, _, _, _, row), do: row
  def build_row(width, h, trans, depth, row) do
    pixel = trans.(width, h)
    {:set, i} = Brot.mandelbrot(pixel, depth)
    pixel = Color.convert(i, depth)
    build_row(width - 1, h, trans, depth, [pixel|row])
  end
end


defmodule Brot do
  def mandelbrot(c, m) do
    z0 = Cmplx.new(0,0)
    i = 0
    test(i, z0, c, m)
  end

  def test(i, z, c, m) when i < m do
    if Cmplx.abs(z) > 2 do
      {:set, i}
    else
      z = Cmplx.add(Cmplx.square(z), c)
      test(i + 1, z, c, m)
    end
  end

  def test(_,_,_,_), do: {:set, 0}
end
defmodule Brot2 do
  def mandelbrot(c, m) do
    z0 = Cmplx.new(0,0)
    i = 0
    test(i, z0, c, m, [])
  end

  def check(_, []), do: false
  def check(value, [h|t]) do
    if value < h do
      IO.puts("comparing")
      IO.inspect([h|t])
      IO.inspect(value)
      false
    else
      check(value, t)
    end
  end

  def test(i, z, c, m, list) when i < m do
    abs = Cmplx.abs(z)
    if abs > 2 do
      {:set, i}
    else
      z = Cmplx.add(Cmplx.square(z), c)
      test(i + 1, z, c, m, [abs|list])
    end
  end

  def test(_,_,_,_,list) do
    IO.inspect(list)
    {:set, 0}
  end
end
