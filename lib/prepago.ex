defmodule Prepago do
  @moduledoc """
    Modulo de Prepago para realizacao de chamadas e impressao de contas de um assinante com plano `prepago`

  Funcao mais utilizada do modulo `Prepago.fazer_chamada/3`
  """
  defstruct creditos: 0, recargas: []
  @preco_minuto 1.45

  @doc """
  Funcao para um assinante fazer uma chamada

  ## Parametros da funcao

  - numero: numero de um assinante que sera feito a chamada
  - data: data correspondente a chamada
  - duracao: duracao da chamada

  ## Exemplo

      iex> Pospago.fazer_chamada("123", DateTime.utc_now(), 10)
      {:error, "Assinante nao existe"}
  """
  def fazer_chamada(numero, data, duracao) do
    cond do
      Assinante.buscar_assinante(numero, :prepago) != nil ->
        assinante = Assinante.buscar_assinante(numero, :prepago)
        custo = @preco_minuto * duracao

        cond do
          custo <= assinante.plano.creditos ->
            plano = assinante.plano
            plano = %__MODULE__{plano | creditos: plano.creditos - custo}

            %Assinante{assinante | plano: plano}
            |> Chamada.registrar(data, duracao)

            {:ok, "A chamada custou #{custo}, e voce tem #{plano.creditos} de creditos"}

          true ->
            {:error, "Voce nao tem creditos para fazer a ligacao, faca uma recarga"}
        end

      Assinante.buscar_assinante(numero, :prepago) == nil ->
        {:error, "Assinante nao existe"}
    end
  end

  @doc """
  Metodo imprime as contas do assinante `prepago` utilizando o metodo `Contas.imprimir/4`, e tambem calculando o total gasto, atirbuindo ao assinante em questao

  ## Parametros da funcao

  - mes: mes que sera aplicado o filtro
  - ano: ano que sera aplicado o filtro
  - numero: numero do assinante que vai querer imprimir as contas

  ## Exemplo

      iex> Pospago.imprimir_conta(12, 2020, "123")
      {:error, "Nao existe assinante com esse numero"}
  """
  def imprimir_conta(mes, ano, numero) do
    cond do
      Assinante.buscar_assinante(numero) != nil ->
        Contas.imprimir(mes, ano, numero, :prepago)

      Assinante.buscar_assinante(numero) == nil ->
        {:error, "Nao existe assinante com esse numero"}
    end
  end
end
