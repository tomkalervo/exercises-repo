defmodule Cmplx do

  # Complex number: {real, imaginary}
  def new(r, i) do
    cond do
      !is_number(r) ->
        :error
      !is_number(i) ->
        :error
      true -> {r, i}
    end
  end

  def add({ar, ai}, {br, bi}), do: {ar + br, ai + bi}

  def square({r, i}) do
    {:math.pow(r,2) - :math.pow(i,2), 2 * r * i}
  end

  # modulus, distance from origin, of a
  # complex number is
  # |a + bi| = sqrt(a^2 + b^2)
  def abs({r, i}) do
    :math.sqrt(
      :math.pow(r,2) + :math.pow(i,2)
    )
  end

end
