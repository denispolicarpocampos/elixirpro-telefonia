defmodule Recarga do
  @moduledoc """
  Modulo de Recarga para que um assinante `prepago` possa fazer uma recarga
  """
  defstruct data: nil, valor: nil

  @doc """
  Funcao para que um assinante `prepago` possa fazer uma nova recarga

  ## Parametros da funcao

  - data: data em que a recarga esta sendo feita
  - valor: valor da recarga
  - numero: numero do assinante que fara a recarga

  ## Exemplo

      iex> Recarga.nova(DateTime.utc_now(), 30, "123")
      {:error, "Assinante nao existe"}
  """
  def nova(data, valor, numero) do
    cond do
      Assinante.buscar_assinante(numero) != nil ->
        assinante = Assinante.buscar_assinante(numero, :prepago)
        plano = assinante.plano

        plano = %Prepago{
          plano
          | creditos: plano.creditos + valor,
            recargas: plano.recargas ++ [%__MODULE__{data: data, valor: valor}]
        }

        assinante = %Assinante{assinante | plano: plano}
        Assinante.atualizar(numero, assinante)

        {:ok, "Recarga realizada com sucesso"}

      Assinante.buscar_assinante(numero) == nil ->
        {:error, "Assinante nao existe"}
    end
  end
end
