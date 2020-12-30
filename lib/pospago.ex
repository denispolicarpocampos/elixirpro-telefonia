defmodule Pospago do
  @moduledoc """
  Modulo de Pospago para realizacao de chamadas e impressao de contas de um assinante com plano `pospago`

  Funcao mais utilizada do modulo `Pospago.fazer_chamada/3`
  """
  defstruct valor: 0
  @custo_minuto 1.40

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
      Assinante.buscar_assinante(numero, :pospago) != nil ->
        Assinante.buscar_assinante(numero, :pospago)
        |> Chamada.registrar(data, duracao)

        {:ok, "Chamada feita com sucesso! Duracao #{duracao} minutos"}

      Assinante.buscar_assinante(numero, :pospago) == nil ->
        {:error, "Assinante nao existe"}
    end
  end

  @doc """
  Metodo imprime as contas do assinante `pospago` utilizando o metodo `Contas.imprimir/4`, e tambem calculando o total gasto, atirbuindo ao assinante em questao

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
        assinante = Contas.imprimir(mes, ano, numero, :pospago)

        valor_total =
          assinante.chamadas
          |> Enum.map(&(&1.duracao * @custo_minuto))
          |> Enum.sum()

        %Assinante{assinante | plano: %__MODULE__{valor: valor_total}}

      Assinante.buscar_assinante(numero) == nil ->
        {:error, "Nao existe assinante com esse numero"}
    end
  end
end
