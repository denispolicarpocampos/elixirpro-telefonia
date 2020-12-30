defmodule Chamada do
  @moduledoc """
  Modulo de Chamada, para fazer o registro de uma nova chamada e atualizar no assinante
  """
  defstruct data: nil, duracao: nil

  @doc """
  Funcao que faz o registro de uma nova chamada, chamando o metodo `Assinante.atualizar/2` para atualizar os dados no assinante.

  ## Parametros da funcao

  - assinante: assinante que fara a chamada
  - data: passando a data atual
  - duracao: duracao da chamada

  ## Informacoes adicionais

  - Se o assinante nao existir a funcao retorara uma tupla com erro e mensagem

  ## Exemplo

      iex> Chamada.registrar(%Assinante{nome: "Teste", numero: "123", cpf: "123", plano: :pospago}, DateTime.utc_now(), 10)
      {:error, "Assinante nao existe"}

  """
  def registrar(assinante, data, duracao) do
    cond do
      Assinante.buscar_assinante(assinante.numero) != nil ->
        assinante_atualizado = %Assinante{
          assinante
          | chamadas: assinante.chamadas ++ [%__MODULE__{data: data, duracao: duracao}]
        }

        Assinante.atualizar(assinante.numero, assinante_atualizado)
        {:ok, "Registro feito com sucesso!"}

      Assinante.buscar_assinante(assinante.numero) == nil ->
        {:error, "Assinante nao existe"}
    end
  end
end
