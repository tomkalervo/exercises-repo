defmodule Table do

  def ratios() do
    if File.exists?("table_20_50.tex") do File.rm("table_20_50.tex") end
    {:ok, file1} = File.open("table_20_50.tex", [:read, :utf8, :write])

    if File.exists?("table_200_50.tex") do File.rm("table_200_50.tex") end
    {:ok, file2} = File.open("table_200_50.tex", [:read, :utf8, :write])

    if File.exists?("table_20_500.tex") do File.rm("table_20_500.tex") end
    {:ok, file3} = File.open("table_20_500.tex", [:read, :utf8, :write])

    #{:ok, as} = File.open("data_as_200_50.txt", [:read, :utf8])
    #{:ok, to} = File.open("data_to_200_50.txt", [:read, :utf8])
    #{:ok, w} = File.open("data_w_200_50.txt", [:read, :utf8])

    to = File.stream!("data_to_20_50.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()
    as = File.stream!("data_as_20_50.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()
    w = File.stream!("data_w_20_50.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()

    IO.binwrite(file1, "\\begin{center}\n\\begin{tabular}{ l | l l | l | l }\n")
    IO.binwrite(file1, "\\textbf{Hunger(h)} & \\multicolumn{2}{l|}{\\textbf{Synchronous}} & \\textbf{Asynchronous} & \\textbf{Waiter}\\\\\n")

    write(file1, to, as, w)
    File.close(file1)

    to = File.stream!("data_to_200_50.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()
    as = File.stream!("data_as_200_50.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()
    w = File.stream!("data_w_200_50.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()

    IO.binwrite(file2, "\\begin{center}\n\\begin{tabular}{ l | l l | l | l }\n")
    IO.binwrite(file2, "\\textbf{Hunger(h)} & \\multicolumn{2}{l|}{\\textbf{Synchronous}} & \\textbf{Asynchronous} & \\textbf{Waiter}\\\\\n")

    write(file2, to, as, w)
    File.close(file2)

    to = File.stream!("data_to_20_500.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()
    as = File.stream!("data_as_20_500.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()
    w = File.stream!("data_w_20_500.txt", [], :line)
    |> Stream.map(fn(line) -> String.split(line, ["\t", "\n"]) end)
    |> Enum.to_list()

    IO.binwrite(file3, "\\begin{center}\n\\begin{tabular}{ l | l l | l | l }\n")
    IO.binwrite(file3, "\\textbf{Hunger(h)} & \\multicolumn{2}{l|}{\\textbf{Synchronous}} & \\textbf{Asynchronous} & \\textbf{Waiter}\\\\\n")

    write(file3, to, as, w)
    File.close(file3)

  end

  def write(file, [], [], []) do
    IO.binwrite(file, "\\end{tabular}\n\\end{center}\n")
  end
  def write(file, [[n,_,to_h,_]|to_t], [[n,_,as_h,_]|as_t], [[n,_,w_h,_]|w_t]) do
    w = Float.round(String.to_integer(w_h) / String.to_integer(to_h), 2)
    as = Float.round(String.to_integer(as_h) / String.to_integer(to_h), 2)
    to = round(String.to_integer(to_h) / 10)
    to = to * 10

    IO.binwrite(file, "#{n} & #{to} & ms/h & #{as} & #{w}\\\\\n")

    write(file, to_t, as_t, w_t)
  end
end
